import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { InformeGenerado, Prisma } from '@prisma/client';

@Injectable()
export class ReportsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCaseId(casoId: string): Promise<InformeGenerado[]> {
    return this.prisma.informeGenerado.findMany({
      where: { caso_id: casoId },
      orderBy: { generado_en: 'desc' },
    });
  }

  async findById(id: string): Promise<InformeGenerado | null> {
    return this.prisma.informeGenerado.findUnique({
      where: { id },
    });
  }

  async findRecent(
    casoId: string,
    tipo: string,
    formato: string,
    minutesAgo: number,
  ): Promise<InformeGenerado | null> {
    const cutoff = new Date(Date.now() - minutesAgo * 60 * 1000);
    return this.prisma.informeGenerado.findFirst({
      where: {
        caso_id: casoId,
        tipo_informe: tipo as any,
        formato: formato as any,
        generado_en: { gte: cutoff },
      },
      orderBy: { generado_en: 'desc' },
    });
  }

  async create(data: Prisma.InformeGeneradoUncheckedCreateInput): Promise<InformeGenerado> {
    return this.prisma.informeGenerado.create({ data });
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
