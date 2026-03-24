import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { Prueba } from '@prisma/client';
import { EvidenceRepository } from './evidence.repository';
import { CreateEvidenceDto } from './dto/create-evidence.dto';
import { UpdateEvidenceDto } from './dto/update-evidence.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class EvidenceService {
  constructor(private readonly repository: EvidenceRepository) {}

  async create(
    casoId: string,
    dto: CreateEvidenceDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Prueba> {
    await this.checkCaseAccess(casoId, userId, perfil);

    if (dto.hecho_id) {
      const hechoValid = await this.repository.hechoExistsInCase(dto.hecho_id, casoId);
      if (!hechoValid) {
        throw new ConflictException('El hecho no pertenece al mismo caso');
      }
    }

    return this.repository.create({
      caso_id: casoId,
      descripcion: dto.descripcion,
      tipo_prueba: dto.tipo_prueba,
      hecho_id: dto.hecho_id ?? null,
      hecho_descripcion_libre: dto.hecho_descripcion_libre ?? null,
      licitud: dto.licitud,
      legalidad: dto.legalidad,
      suficiencia: dto.suficiencia,
      credibilidad: dto.credibilidad,
      posicion_defensiva: dto.posicion_defensiva ?? null,
      creado_por: userId,
      actualizado_por: userId,
    });
  }

  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Prueba[]> {
    await this.checkCaseAccess(casoId, userId, perfil);
    return this.repository.findByCaseId(casoId);
  }

  async findOne(
    casoId: string,
    evidenceId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Prueba> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const prueba = await this.repository.findById(evidenceId);
    if (!prueba || prueba.caso_id !== casoId) {
      throw new NotFoundException(`Prueba ${evidenceId} no encontrada`);
    }

    return prueba;
  }

  async update(
    casoId: string,
    evidenceId: string,
    dto: UpdateEvidenceDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Prueba> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const prueba = await this.repository.findById(evidenceId);
    if (!prueba || prueba.caso_id !== casoId) {
      throw new NotFoundException(`Prueba ${evidenceId} no encontrada`);
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    if (dto.descripcion !== undefined) updateData.descripcion = dto.descripcion;
    if (dto.tipo_prueba !== undefined) updateData.tipo_prueba = dto.tipo_prueba;
    if (dto.hecho_descripcion_libre !== undefined) updateData.hecho_descripcion_libre = dto.hecho_descripcion_libre;
    if (dto.licitud !== undefined) updateData.licitud = dto.licitud;
    if (dto.legalidad !== undefined) updateData.legalidad = dto.legalidad;
    if (dto.suficiencia !== undefined) updateData.suficiencia = dto.suficiencia;
    if (dto.credibilidad !== undefined) updateData.credibilidad = dto.credibilidad;
    if (dto.posicion_defensiva !== undefined) updateData.posicion_defensiva = dto.posicion_defensiva;

    return this.repository.update(evidenceId, updateData);
  }

  async link(
    casoId: string,
    evidenceId: string,
    hechoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Prueba> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const prueba = await this.repository.findById(evidenceId);
    if (!prueba || prueba.caso_id !== casoId) {
      throw new NotFoundException(`Prueba ${evidenceId} no encontrada`);
    }

    const hechoValid = await this.repository.hechoExistsInCase(hechoId, casoId);
    if (!hechoValid) {
      throw new ConflictException('El hecho no pertenece al mismo caso');
    }

    return this.repository.update(evidenceId, {
      hecho_id: hechoId,
      actualizado_por: userId,
    });
  }

  async unlink(
    casoId: string,
    evidenceId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Prueba> {
    await this.checkCaseAccess(casoId, userId, perfil);

    const prueba = await this.repository.findById(evidenceId);
    if (!prueba || prueba.caso_id !== casoId) {
      throw new NotFoundException(`Prueba ${evidenceId} no encontrada`);
    }

    return this.repository.update(evidenceId, {
      hecho_id: null,
      actualizado_por: userId,
    });
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