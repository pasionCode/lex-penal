import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { Hecho } from '@prisma/client';
import { FactsRepository } from './facts.repository';
import { CreateFactDto } from './dto/create-fact.dto';
import { UpdateFactDto } from './dto/update-fact.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class FactsService {
  constructor(private readonly repository: FactsRepository) {}

  async create(
    casoId: string,
    dto: CreateFactDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Hecho> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const orden = await this.repository.getNextOrder(casoId);

    return this.repository.create({
      caso_id: casoId,
      orden,
      descripcion: dto.descripcion,
      estado_hecho: dto.estado_hecho,
      fuente: dto.fuente ?? null,
      incidencia_juridica: dto.incidencia_juridica ?? null,
      creado_por: userId,
      actualizado_por: userId,
    });
  }

  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Hecho[]> {
    await this.checkCaseAccess(casoId, userId, perfil);
    return this.repository.findByCaseId(casoId);
  }

  async findOne(
    casoId: string,
    factId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Hecho> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const hecho = await this.repository.findById(factId);
    if (!hecho || hecho.caso_id !== casoId) {
      throw new NotFoundException(`Hecho ${factId} no encontrado`);
    }

    return hecho;
  }

  async update(
    casoId: string,
    factId: string,
    dto: UpdateFactDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Hecho> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const hecho = await this.repository.findById(factId);
    if (!hecho || hecho.caso_id !== casoId) {
      throw new NotFoundException(`Hecho ${factId} no encontrado`);
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    if (dto.descripcion !== undefined) updateData.descripcion = dto.descripcion;
    if (dto.estado_hecho !== undefined) updateData.estado_hecho = dto.estado_hecho;
    if (dto.fuente !== undefined) updateData.fuente = dto.fuente;
    if (dto.incidencia_juridica !== undefined) updateData.incidencia_juridica = dto.incidencia_juridica;

    return this.repository.update(factId, updateData);
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