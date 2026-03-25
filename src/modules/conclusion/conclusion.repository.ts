import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { ConclusionOperativa, Prisma } from '@prisma/client';

@Injectable()
export class ConclusionRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCaseId(casoId: string): Promise<ConclusionOperativa | null> {
    return this.prisma.conclusionOperativa.findUnique({
      where: { caso_id: casoId },
    });
  }

  async create(data: Prisma.ConclusionOperativaUncheckedCreateInput): Promise<ConclusionOperativa> {
    return this.prisma.conclusionOperativa.create({ data });
  }

  async update(casoId: string, data: Prisma.ConclusionOperativaUncheckedUpdateInput): Promise<ConclusionOperativa> {
    return this.prisma.conclusionOperativa.update({
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