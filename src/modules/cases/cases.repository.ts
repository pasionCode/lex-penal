import { Injectable } from '@nestjs/common';
import { Caso, Prisma } from '@prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';

type CasoWithRelations = Prisma.CasoGetPayload<{
  include: {
    cliente: { select: { id: true; nombre: true } };
    responsable: { select: { id: true; nombre: true } };
  };
}>;

@Injectable()
export class CasesRepository {
  constructor(private readonly prisma: PrismaService) {}

  async create(data: Prisma.CasoCreateInput): Promise<Caso> {
    return this.prisma.caso.create({ data });
  }

  async findById(id: string): Promise<Caso | null> {
    return this.prisma.caso.findUnique({ where: { id } });
  }

  async findByRadicado(radicado: string): Promise<Caso | null> {
    return this.prisma.caso.findUnique({ where: { radicado } });
  }

  async findByResponsable(responsableId: string): Promise<Caso[]> {
    return this.prisma.caso.findMany({
      where: { responsable_id: responsableId },
      orderBy: { creado_en: 'desc' },
    });
  }

  async findAll(): Promise<Caso[]> {
    return this.prisma.caso.findMany({
      orderBy: { creado_en: 'desc' },
    });
  }

  async findByIdWithRelations(id: string): Promise<CasoWithRelations | null> {
    return this.prisma.caso.findUnique({
      where: { id },
      include: {
        cliente: { select: { id: true, nombre: true } },
        responsable: { select: { id: true, nombre: true } },
      },
    });
  }

  async clienteExists(clienteId: string): Promise<boolean> {
    const cliente = await this.prisma.cliente.findUnique({
      where: { id: clienteId },
      select: { id: true },
    });
    return !!cliente;
  }

  async update(id: string, data: Prisma.CasoUpdateInput): Promise<Caso> {
    return this.prisma.caso.update({ where: { id }, data });
  }
}
