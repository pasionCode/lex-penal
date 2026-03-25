import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { Estrategia, Prisma } from '@prisma/client';

@Injectable()
export class StrategyRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCaseId(casoId: string): Promise<Estrategia | null> {
    return this.prisma.estrategia.findUnique({
      where: { caso_id: casoId },
    });
  }

  async create(data: Prisma.EstrategiaUncheckedCreateInput): Promise<Estrategia> {
    return this.prisma.estrategia.create({ data });
  }

  async update(casoId: string, data: Prisma.EstrategiaUncheckedUpdateInput): Promise<Estrategia> {
    return this.prisma.estrategia.update({
      where: { caso_id: casoId },
      data,
    });
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