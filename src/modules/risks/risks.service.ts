import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { Riesgo } from '@prisma/client';
import { RisksRepository } from './risks.repository';
import { CreateRiskDto, Prioridad } from './dto/create-risk.dto';
import { UpdateRiskDto } from './dto/update-risk.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class RisksService {
  constructor(private readonly repository: RisksRepository) {}

  async create(
    casoId: string,
    dto: CreateRiskDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Riesgo> {
    await this.checkCaseAccess(casoId, userId, perfil);

    // Validar: prioridad crítica requiere estrategia_mitigacion
    if (dto.prioridad === Prioridad.CRITICA && !dto.estrategia_mitigacion) {
      throw new BadRequestException('Riesgo con prioridad critica requiere estrategia_mitigacion');
    }

    return this.repository.create({
      caso_id: casoId,
      descripcion: dto.descripcion,
      probabilidad: dto.probabilidad,
      impacto: dto.impacto,
      prioridad: dto.prioridad,
      estrategia_mitigacion: dto.estrategia_mitigacion ?? null,
      estado_mitigacion: dto.estado_mitigacion ?? 'pendiente',
      plazo_accion: dto.plazo_accion ? new Date(dto.plazo_accion) : null,
      responsable_id: dto.responsable_id ?? null,
      creado_por: userId,
      actualizado_por: userId,
    });
  }

  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Riesgo[]> {
    await this.checkCaseAccess(casoId, userId, perfil);
    return this.repository.findByCaseId(casoId);
  }

  async findOne(
    casoId: string,
    riskId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Riesgo> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const riesgo = await this.repository.findById(riskId);
    if (!riesgo || riesgo.caso_id !== casoId) {
      throw new NotFoundException(`Riesgo ${riskId} no encontrado`);
    }

    return riesgo;
  }

  async update(
    casoId: string,
    riskId: string,
    dto: UpdateRiskDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Riesgo> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const riesgo = await this.repository.findById(riskId);
    if (!riesgo || riesgo.caso_id !== casoId) {
      throw new NotFoundException(`Riesgo ${riskId} no encontrado`);
    }

    // Validar: si se actualiza a prioridad crítica, debe tener estrategia
    const nuevaPrioridad = dto.prioridad ?? riesgo.prioridad;
    const nuevaEstrategia = dto.estrategia_mitigacion ?? riesgo.estrategia_mitigacion;
    if (nuevaPrioridad === 'critica' && !nuevaEstrategia) {
      throw new BadRequestException('Riesgo con prioridad critica requiere estrategia_mitigacion');
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    if (dto.descripcion !== undefined) updateData.descripcion = dto.descripcion;
    if (dto.probabilidad !== undefined) updateData.probabilidad = dto.probabilidad;
    if (dto.impacto !== undefined) updateData.impacto = dto.impacto;
    if (dto.prioridad !== undefined) updateData.prioridad = dto.prioridad;
    if (dto.estrategia_mitigacion !== undefined) updateData.estrategia_mitigacion = dto.estrategia_mitigacion;
    if (dto.estado_mitigacion !== undefined) updateData.estado_mitigacion = dto.estado_mitigacion;
    if (dto.plazo_accion !== undefined) updateData.plazo_accion = new Date(dto.plazo_accion);
    if (dto.responsable_id !== undefined) updateData.responsable_id = dto.responsable_id;

    return this.repository.update(riskId, updateData);
  }

  private async checkCaseAccess(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<void> {
    const exists = await this.repository.caseExists(casoId);
    if (!exists) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(casoId);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }
  }
}