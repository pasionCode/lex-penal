import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { RevisionSupervisor, Prisma } from '@prisma/client';

@Injectable()
export class ReviewRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCaseId(casoId: string): Promise<RevisionSupervisor[]> {
    return this.prisma.revisionSupervisor.findMany({
      where: { caso_id: casoId },
      orderBy: { version_revision: 'desc' },
    });
  }

  async findVigente(casoId: string): Promise<RevisionSupervisor | null> {
    return this.prisma.revisionSupervisor.findFirst({
      where: { caso_id: casoId, vigente: true },
    });
  }

  async getNextVersion(casoId: string): Promise<number> {
    const last = await this.prisma.revisionSupervisor.findFirst({
      where: { caso_id: casoId },
      orderBy: { version_revision: 'desc' },
      select: { version_revision: true },
    });
    return (last?.version_revision ?? 0) + 1;
  }

  async create(data: Prisma.RevisionSupervisorUncheckedCreateInput): Promise<RevisionSupervisor> {
    return this.prisma.revisionSupervisor.create({ data });
  }

  async markPreviousAsNotVigente(casoId: string): Promise<void> {
    await this.prisma.revisionSupervisor.updateMany({
      where: { caso_id: casoId, vigente: true },
      data: { vigente: false },
    });
  }

  async caseExists(casoId: string): Promise<boolean> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { id: true },
    });
    return !!caso;
  }

  async getCaseState(casoId: string): Promise<string | null> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { estado_actual: true },
    });
    return caso?.estado_actual ?? null;
  }

  async getCaseResponsable(casoId: string): Promise<string | null> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { responsable_id: true },
    });
    return caso?.responsable_id ?? null;
  }
}
