import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { Prueba, Prisma } from '@prisma/client';

@Injectable()
export class EvidenceRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: Prisma.PruebaUncheckedCreateInput): Promise<Prueba> {
    return this.prisma.prueba.create({ data });
  }

  async findById(id: string): Promise<Prueba | null> {
    return this.prisma.prueba.findUnique({ where: { id } });
  }

  async findByCaseId(casoId: string): Promise<Prueba[]> {
    return this.prisma.prueba.findMany({
      where: { caso_id: casoId },
      orderBy: { creado_en: 'asc' },
    });
  }

  async update(id: string, data: Prisma.PruebaUncheckedUpdateInput): Promise<Prueba> {
    return this.prisma.prueba.update({ where: { id }, data });
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

  async hechoExistsInCase(hechoId: string, casoId: string): Promise<boolean> {
    const hecho = await this.prisma.hecho.findFirst({
      where: { id: hechoId, caso_id: casoId },
      select: { id: true },
    });
    return !!hecho;
  }
}