import { Injectable } from '@nestjs/common';
import { Cliente, Prisma } from '@prisma/client';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';

/**
 * Repositorio de clients.
 * Único punto de acceso a la persistencia del módulo.
 */
@Injectable()
export class ClientsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(): Promise<Cliente[]> {
    return this.prisma.cliente.findMany({
      orderBy: { creado_en: 'desc' },
    });
  }

  async findById(id: string): Promise<Cliente | null> {
    return this.prisma.cliente.findUnique({ where: { id } });
  }

  async findByDocument(
    tipoDocumento: string,
    documento: string,
  ): Promise<Cliente | null> {
    return this.prisma.cliente.findUnique({
      where: {
        tipo_documento_documento: {
          tipo_documento: tipoDocumento,
          documento,
        },
      },
    });
  }

  async create(data: Prisma.ClienteUncheckedCreateInput): Promise<Cliente> {
    return this.prisma.cliente.create({ data });
  }

  async update(
    id: string,
    data: Prisma.ClienteUncheckedUpdateInput,
  ): Promise<Cliente> {
    return this.prisma.cliente.update({ where: { id }, data });
  }
}
