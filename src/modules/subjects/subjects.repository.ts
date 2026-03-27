import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { CreateSubjectDto } from './dto/create-subject.dto';

@Injectable()
export class SubjectsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAllByCaseId(caseId: string) {
    return this.prisma.subject.findMany({
      where: { caso_id: caseId },
      orderBy: { creado_en: 'desc' },
    });
  }

  async findById(subjectId: string) {
    return this.prisma.subject.findUnique({
      where: { id: subjectId },
    });
  }

  async create(caseId: string, dto: CreateSubjectDto, userId: string) {
    return this.prisma.subject.create({
      data: {
        caso_id: caseId,
        tipo: dto.tipo,
        nombre: dto.nombre,
        identificacion: dto.identificacion,
        tipo_identificacion: dto.tipo_identificacion,
        contacto: dto.contacto,
        direccion: dto.direccion,
        notas: dto.notas,
        creado_por: userId,
      },
    });
  }

  async caseExists(caseId: string): Promise<boolean> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: caseId },
      select: { id: true },
    });
    return !!caso;
  }
}
