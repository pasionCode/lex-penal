import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { TipoEvento, EventoAuditoria, Usuario } from '@prisma/client';

/**
 * Evento de auditoría con usuario incluido.
 */
export type EventoConUsuario = EventoAuditoria & {
  usuario: Pick<Usuario, 'id' | 'nombre'>;
};

/**
 * Resultado de consulta paginada de eventos.
 */
export interface AuditQueryResult {
  data: EventoConUsuario[];
  total: number;
}

/**
 * Repositorio de audit.
 * Único punto de acceso a la persistencia del módulo.
 * Depende de PrismaService (ADR-006).
 */
@Injectable()
export class AuditRepository {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Consulta eventos de auditoría de un caso con paginación y filtros.
   *
   * @param casoId ID del caso
   * @param filtros Filtros opcionales (tipo, page, per_page)
   * @returns Eventos paginados con total
   */
  async findByCaso(
    casoId: string,
    filtros: {
      tipo?: TipoEvento;
      page?: number;
      per_page?: number;
    },
  ): Promise<AuditQueryResult> {
    const page = filtros.page || 1;
    const perPage = filtros.per_page || 20;
    const skip = (page - 1) * perPage;

    // Construir condición WHERE con tipos correctos de Prisma
    const where = {
      caso_id: casoId,
      ...(filtros.tipo && { tipo_evento: filtros.tipo }),
    };

    // Consulta paralela: datos + count
    const [data, total] = await Promise.all([
      this.prisma.eventoAuditoria.findMany({
        where,
        include: {
          usuario: {
            select: {
              id: true,
              nombre: true,
            },
          },
        },
        orderBy: {
          fecha_evento: 'desc',
        },
        skip,
        take: perPage,
      }),
      this.prisma.eventoAuditoria.count({ where }),
    ]);

    return { data, total };
  }

  /**
   * Verifica si un caso existe.
   *
   * @param casoId ID del caso
   * @returns true si existe, false si no
   */
  async casoExists(casoId: string): Promise<boolean> {
    const caso = await this.prisma.caso.findUnique({
      where: { id: casoId },
      select: { id: true },
    });
    return caso !== null;
  }
}
