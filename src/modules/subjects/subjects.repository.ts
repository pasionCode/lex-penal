import { Injectable } from '@nestjs/common';
import { Prisma, TipoIdentificacion, TipoSujeto } from '@prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { CreateSubjectDto } from './dto/create-subject.dto';

@Injectable()
export class SubjectsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAllByCaseId(
    caseId: string,
    page: number,
    perPage: number,
    tipo?: TipoSujeto,
    nombre?: string,
    identificacion?: string,
    tipoIdentificacion?: TipoIdentificacion,
  ): Promise<{ data: any[]; total: number }> {
    const skip = (page - 1) * perPage;

    const whereClause: Prisma.SubjectWhereInput = {
      caso_id: caseId,
    };

    if (tipo) {
      whereClause.tipo = tipo;
    }

    if (nombre) {
      whereClause.nombre = {
        contains: nombre,
        mode: 'insensitive',
      };
    }

    if (identificacion) {
      whereClause.identificacion = identificacion;
    }

    if (tipoIdentificacion) {
      whereClause.tipo_identificacion = tipoIdentificacion;
    }

    const [data, total] = await Promise.all([
      this.prisma.subject.findMany({
        where: whereClause,
        orderBy: { creado_en: 'desc' },
        skip,
        take: perPage,
      }),
      this.prisma.subject.count({
        where: whereClause,
      }),
    ]);

    return { data, total };
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
