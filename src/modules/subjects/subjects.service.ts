import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { SubjectsRepository } from './subjects.repository';
import { CreateSubjectDto } from './dto/create-subject.dto';
import { TipoIdentificacion, TipoSujeto } from '@prisma/client';
import { PerfilUsuario } from '../../types/enums';

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
}

@Injectable()
export class SubjectsService {
  constructor(private readonly repository: SubjectsRepository) {}

  private async assertCaseAccess(
    caseId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<void> {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }

    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(caseId);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }
  }

  async findAllByCaseId(
    caseId: string,
    userId: string,
    perfil: PerfilUsuario,
    page: number,
    perPage: number,
    tipo?: TipoSujeto,
    nombre?: string,
    identificacion?: string,
    tipoIdentificacion?: TipoIdentificacion,
  ): Promise<PaginatedResponse<any>> {
    await this.assertCaseAccess(caseId, userId, perfil);

    const { data, total } = await this.repository.findAllByCaseId(
      caseId,
      page,
      perPage,
      tipo,
      nombre,
      identificacion,
      tipoIdentificacion,
    );

    return {
      data,
      total,
      page,
      per_page: perPage,
    };
  }

  async findOne(
    caseId: string,
    subjectId: string,
    userId: string,
    perfil: PerfilUsuario,
  ) {
    await this.assertCaseAccess(caseId, userId, perfil);

    const subject = await this.repository.findById(subjectId);
    if (!subject || subject.caso_id !== caseId) {
      throw new NotFoundException('Sujeto no encontrado');
    }
    return subject;
  }

  async create(
    caseId: string,
    dto: CreateSubjectDto,
    userId: string,
    perfil: PerfilUsuario,
  ) {
    await this.assertCaseAccess(caseId, userId, perfil);
    return this.repository.create(caseId, dto, userId);
  }
}
