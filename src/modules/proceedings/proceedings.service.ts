import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { Actuacion } from '@prisma/client';
import { ProceedingsRepository } from './proceedings.repository';
import { CreateProceedingDto } from './dto/create-proceeding.dto';
import { UpdateProceedingDto } from './dto/update-proceeding.dto';
import { PerfilUsuario } from '../../types/enums';

@Injectable()
export class ProceedingsService {
  constructor(private readonly repository: ProceedingsRepository) {}

  async findAll(
    caseId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Actuacion[]> {
    await this.validateCaseAccess(caseId, userId, perfil);
    return this.repository.findAllByCaseId(caseId);
  }

  async findOne(
    caseId: string,
    proceedingId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Actuacion> {
    await this.validateCaseAccess(caseId, userId, perfil);
    const proceeding = await this.repository.findById(proceedingId);
    if (!proceeding || proceeding.caso_id !== caseId) {
      throw new NotFoundException(`Actuación ${proceedingId} no encontrada`);
    }
    return proceeding;
  }

  async create(
    caseId: string,
    dto: CreateProceedingDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Actuacion> {
    await this.validateCaseAccess(caseId, userId, perfil);

    return this.repository.create({
      caso_id: caseId,
      descripcion: dto.descripcion,
      fecha: dto.fecha ? new Date(dto.fecha) : undefined,
      responsable_id: dto.responsable_id,
      responsable_externo: dto.responsable_externo,
      completada: dto.completada ?? false,
      creado_por: userId,
    });
  }

  async update(
    caseId: string,
    proceedingId: string,
    dto: UpdateProceedingDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Actuacion> {
    await this.validateCaseAccess(caseId, userId, perfil);

    const existing = await this.repository.findById(proceedingId);
    if (!existing || existing.caso_id !== caseId) {
      throw new NotFoundException(`Actuación ${proceedingId} no encontrada`);
    }

    return this.repository.update(proceedingId, {
      descripcion: dto.descripcion,
      fecha: dto.fecha ? new Date(dto.fecha) : undefined,
      responsable_id: dto.responsable_id,
      responsable_externo: dto.responsable_externo,
      completada: dto.completada,
      actualizado_por: userId,
    });
  }

  async remove(
    caseId: string,
    proceedingId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<Actuacion> {
    await this.validateCaseAccess(caseId, userId, perfil);

    const existing = await this.repository.findById(proceedingId);
    if (!existing || existing.caso_id !== caseId) {
      throw new NotFoundException(`Actuación ${proceedingId} no encontrada`);
    }

    return this.repository.delete(proceedingId);
  }

  private async validateCaseAccess(
    caseId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<void> {
    const exists = await this.repository.caseExists(caseId);
    if (!exists) {
      throw new NotFoundException(`Caso ${caseId} no encontrado`);
    }

    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(caseId);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }
  }
}
