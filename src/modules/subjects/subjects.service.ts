import { Injectable, NotFoundException } from '@nestjs/common';
import { SubjectsRepository } from './subjects.repository';
import { CreateSubjectDto, TipoSujeto } from './dto/create-subject.dto';

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  per_page: number;
}

@Injectable()
export class SubjectsService {
  constructor(private readonly repository: SubjectsRepository) {}

  async findAllByCaseId(
    caseId: string,
    page: number,
    perPage: number,
    tipo?: TipoSujeto,
  ): Promise<PaginatedResponse<any>> {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }

    const { data, total } = await this.repository.findAllByCaseId(
      caseId,
      page,
      perPage,
      tipo,
    );

    return {
      data,
      total,
      page,
      per_page: perPage,
    };
  }

  async findOne(caseId: string, subjectId: string) {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }

    const subject = await this.repository.findById(subjectId);
    if (!subject || subject.caso_id !== caseId) {
      throw new NotFoundException('Sujeto no encontrado');
    }
    return subject;
  }

  async create(caseId: string, dto: CreateSubjectDto, userId: string) {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }
    return this.repository.create(caseId, dto, userId);
  }
}
