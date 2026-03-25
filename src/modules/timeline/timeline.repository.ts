import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { LineaTiempo, Prisma } from '@prisma/client';

@Injectable()
export class TimelineRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: Prisma.LineaTiempoUncheckedCreateInput): Promise<LineaTiempo> {
    return this.prisma.lineaTiempo.create({ data });
  }

  async findByCaseId(casoId: string): Promise<LineaTiempo[]> {
    return this.prisma.lineaTiempo.findMany({
      where: { caso_id: casoId },
      orderBy: [{ fecha_evento: 'asc' }, { orden: 'asc' }],
    });
  }

  async getNextOrder(casoId: string): Promise<number> {
    const last = await this.prisma.lineaTiempo.findFirst({
      where: { caso_id: casoId },
      orderBy: { orden: 'desc' },
      select: { orden: true },
    });
    return (last?.orden ?? 0) + 1;
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
