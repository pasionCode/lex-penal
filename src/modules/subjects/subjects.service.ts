import { Injectable, NotFoundException } from '@nestjs/common';
import { SubjectsRepository } from './subjects.repository';
import { CreateSubjectDto } from './dto/create-subject.dto';

@Injectable()
export class SubjectsService {
  constructor(private readonly repository: SubjectsRepository) {}

  async findAllByCaseId(caseId: string) {
    const caseExists = await this.repository.caseExists(caseId);
    if (!caseExists) {
      throw new NotFoundException('Caso no encontrado');
    }
    return this.repository.findAllByCaseId(caseId);
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
