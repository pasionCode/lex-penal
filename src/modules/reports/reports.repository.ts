import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { InformeGenerado, Prisma } from '@prisma/client';
import { TipoEvento, ResultadoAuditoria } from '../../types/enums';

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

  /**
   * Crea informe y registra evento de auditoría en una sola transacción.
   * E6-02: Operación atómica para evitar deriva.
   *
   * @param data Datos del informe
   * @param casoId ID del caso
   * @param usuarioId ID del usuario que genera el informe
   * @returns InformeGenerado creado
   */
  async createWithAudit(
    data: Prisma.InformeGeneradoUncheckedCreateInput,
    casoId: string,
    usuarioId: string,
  ): Promise<InformeGenerado> {
    return this.prisma.$transaction(async (tx) => {
      // 1. Crear informe
      const informe = await tx.informeGenerado.create({ data });

      // 2. Registrar evento de auditoría
      await tx.eventoAuditoria.create({
        data: {
          caso_id: casoId,
          usuario_id: usuarioId,
          tipo_evento: TipoEvento.INFORME_GENERADO,
          resultado: ResultadoAuditoria.EXITOSO,
        },
      });

      return informe;
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
