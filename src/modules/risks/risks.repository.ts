import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { Riesgo, Prisma } from '@prisma/client';

@Injectable()
export class RisksRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: Prisma.RiesgoUncheckedCreateInput): Promise<Riesgo> {
    return this.prisma.riesgo.create({ data });
  }

  async findById(id: string): Promise<Riesgo | null> {
    return this.prisma.riesgo.findUnique({ where: { id } });
  }

  async findByCaseId(casoId: string): Promise<Riesgo[]> {
    return this.prisma.riesgo.findMany({
      where: { caso_id: casoId },
      orderBy: [{ prioridad: 'asc' }, { creado_en: 'asc' }],
    });
  }

  async update(id: string, data: Prisma.RiesgoUncheckedUpdateInput): Promise<Riesgo> {
    return this.prisma.riesgo.update({ where: { id }, data });
  }

  async caseExists(casoId: string): Promise<boolean> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { id: true },
    });
    return !!caso;
  }

  async getCaseResponsable(casoId: string): Promise<string | null> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { responsable_id: true },
    });
    return caso?.responsable_id ?? null;
  }

  async getCaseState(casoId: string): Promise<string | null> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { estado_actual: true },
    });
    return caso?.estado_actual ?? null;
  }
}
