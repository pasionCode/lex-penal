import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { Documento, CategoriaDocumento } from '@prisma/client';

@Injectable()
export class DocumentsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findAllByCaseId(caseId: string): Promise<Documento[]> {
    return this.prisma.documento.findMany({
      where: { caso_id: caseId },
      orderBy: { subido_en: 'desc' },
    });
  }

  async findById(id: string): Promise<Documento | null> {
    return this.prisma.documento.findUnique({
      where: { id },
    });
  }

  async create(data: {
    caso_id: string;
    categoria: CategoriaDocumento;
    nombre_original: string;
    nombre_almacenado: string;
    ruta: string;
    mime_type: string;
    tamanio_bytes: bigint;
    descripcion?: string;
    subido_por: string;
  }): Promise<Documento> {
    return this.prisma.documento.create({ data });
  }

  async caseExists(caseId: string): Promise<boolean> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: caseId },
      select: { id: true },
    });
    return caso !== null;
  }

  async getCaseResponsable(caseId: string): Promise<string | null> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: caseId },
      select: { responsable_id: true },
    });
    return caso?.responsable_id ?? null;
  }
}
