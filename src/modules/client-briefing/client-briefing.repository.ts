import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { ExplicacionCliente, Prisma } from '@prisma/client';

@Injectable()
export class ClientBriefingRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCaseId(casoId: string): Promise<ExplicacionCliente | null> {
    return this.prisma.explicacionCliente.findUnique({
      where: { caso_id: casoId },
    });
  }

  async create(data: Prisma.ExplicacionClienteUncheckedCreateInput): Promise<ExplicacionCliente> {
    return this.prisma.explicacionCliente.create({ data });
  }

  async update(casoId: string, data: Prisma.ExplicacionClienteUncheckedUpdateInput): Promise<ExplicacionCliente> {
    return this.prisma.explicacionCliente.update({
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
