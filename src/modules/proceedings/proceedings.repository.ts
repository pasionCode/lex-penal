import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { Actuacion } from '@prisma/client';

@Injectable()
export class ProceedingsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAllByCaseId(caseId: string): Promise<Actuacion[]> {
    return this.prisma.actuacion.findMany({
      where: { caso_id: caseId },
      orderBy: { fecha: 'asc' },
    });
  }

  async findById(id: string): Promise<Actuacion | null> {
    return this.prisma.actuacion.findUnique({
      where: { id },
    });
  }

  async create(data: {
    caso_id: string;
    descripcion: string;
    fecha?: Date;
    responsable_id?: string;
    responsable_externo?: string;
    completada: boolean;
    creado_por: string;
  }): Promise<Actuacion> {
    return this.prisma.actuacion.create({ data });
  }

  async update(
    id: string,
    data: {
      descripcion?: string;
      fecha?: Date;
      responsable_id?: string;
      responsable_externo?: string;
      completada?: boolean;
      actualizado_por: string;
    },
  ): Promise<Actuacion> {
    return this.prisma.actuacion.update({
      where: { id },
      data,
    });
  }

  async delete(id: string): Promise<Actuacion> {
    return this.prisma.actuacion.delete({
      where: { id },
    });
  }

  async caseExists(caseId: string): Promise<boolean> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: caseId },
      select: { id: true },
    });
    return caso !== null;
  }

  async getCaseResponsable(caseId: string): Promise<string | null> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: caseId },
      select: { responsable_id: true },
    });
    return caso?.responsable_id ?? null;
  }
}
