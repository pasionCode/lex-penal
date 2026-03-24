import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { Hecho, Prisma } from '@prisma/client';

@Injectable()
export class FactsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: Prisma.HechoUncheckedCreateInput): Promise<Hecho> {
    return this.prisma.hecho.create({ data });
  }

  async findById(id: string): Promise<Hecho | null> {
    return this.prisma.hecho.findUnique({ where: { id } });
  }

  async findByCaseId(casoId: string): Promise<Hecho[]> {
    return this.prisma.hecho.findMany({
      where: { caso_id: casoId },
      orderBy: { orden: 'asc' },
    });
  }

  async getNextOrder(casoId: string): Promise<number> {
    const max = await this.prisma.hecho.aggregate({
      where: { caso_id: casoId },
      _max: { orden: true },
    });
    return (max._max.orden ?? 0) + 1;
  }

  async update(id: string, data: Prisma.HechoUncheckedUpdateInput): Promise<Hecho> {
    return this.prisma.hecho.update({ where: { id }, data });
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
}
