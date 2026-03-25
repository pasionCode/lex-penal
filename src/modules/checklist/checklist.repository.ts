import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { ChecklistBloque, ChecklistItem } from '@prisma/client';

export type BloqueConItems = ChecklistBloque & {
  items: ChecklistItem[];
};

@Injectable()
export class ChecklistRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCaseId(casoId: string): Promise<BloqueConItems[]> {
    return this.prisma.checklistBloque.findMany({
      where: { caso_id: casoId },
      include: {
        items: {
          orderBy: { codigo_item: 'asc' },
        },
      },
      orderBy: { codigo_bloque: 'asc' },
    });
  }

  async findItemById(itemId: string): Promise<ChecklistItem | null> {
    return this.prisma.checklistItem.findUnique({
      where: { id: itemId },
    });
  }

  async updateItem(
    itemId: string,
    marcado: boolean,
    userId: string,
  ): Promise<ChecklistItem> {
    return this.prisma.checklistItem.update({
      where: { id: itemId },
      data: {
        marcado,
        marcado_en: marcado ? new Date() : null,
        marcado_por: marcado ? userId : null,
      },
    });
  }

  async updateBloqueCompletado(bloqueId: string): Promise<ChecklistBloque> {
    const items = await this.prisma.checklistItem.findMany({
      where: { bloque_id: bloqueId },
      select: { marcado: true },
    });

    const completado = items.length > 0 && items.every((i) => i.marcado);

    return this.prisma.checklistBloque.update({
      where: { id: bloqueId },
      data: { completado },
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

  async hasChecklist(casoId: string): Promise<boolean> {
    const count = await this.prisma.checklistBloque.count({
      where: { caso_id: casoId },
    });
    return count > 0;
  }

  async createBaseStructure(casoId: string): Promise<void> {
    const bloques = [
      {
        codigo: 'B01',
        nombre: 'Verificación de hechos',
        critico: true,
        items: [
          { codigo: 'B01_01', descripcion: 'Hechos contrastados con denuncia' },
          { codigo: 'B01_02', descripcion: 'Tipicidad analizada' },
        ],
      },
      {
        codigo: 'B02',
        nombre: 'Análisis probatorio',
        critico: true,
        items: [
          { codigo: 'B02_01', descripcion: 'Pruebas relevantes identificadas' },
          { codigo: 'B02_02', descripcion: 'Licitud y conducencia verificadas' },
        ],
      },
      {
        codigo: 'B03',
        nombre: 'Estrategia defensiva',
        critico: true,
        items: [
          { codigo: 'B03_01', descripcion: 'Línea principal documentada' },
          { codigo: 'B03_02', descripcion: 'Riesgos identificados' },
        ],
      },
    ];

    for (const bloque of bloques) {
      const bloqueCreado = await this.prisma.checklistBloque.create({
        data: {
          caso_id: casoId,
          codigo_bloque: bloque.codigo,
          nombre_bloque: bloque.nombre,
          critico: bloque.critico,
          completado: false,
        },
      });

      for (const item of bloque.items) {
        await this.prisma.checklistItem.create({
          data: {
            bloque_id: bloqueCreado.id,
            caso_id: casoId,
            codigo_item: item.codigo,
            descripcion: item.descripcion,
            marcado: false,
          },
        });
      }
    }
  }
}