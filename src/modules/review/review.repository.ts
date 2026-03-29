import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';
import { RevisionSupervisor, Prisma } from '@prisma/client';
import { TipoEvento, ResultadoAuditoria } from '../../types/enums';

@Injectable()
export class ReviewRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findByCaseId(casoId: string): Promise<RevisionSupervisor[]> {
    return this.prisma.revisionSupervisor.findMany({
      where: { caso_id: casoId },
      orderBy: { version_revision: 'desc' },
    });
  }

  async findVigente(casoId: string): Promise<RevisionSupervisor | null> {
    return this.prisma.revisionSupervisor.findFirst({
      where: { caso_id: casoId, vigente: true },
    });
  }

  /**
   * Crea revisión y registra evento de auditoría en una sola transacción.
   * E6-02: Operación atómica para evitar deriva y race conditions.
   *
   * La versión se calcula dentro de la transacción para evitar
   * condiciones de carrera entre peticiones concurrentes.
   *
   * @param baseData Datos de la revisión (sin version_revision)
   * @param casoId ID del caso
   * @param usuarioId ID del usuario que crea la revisión
   * @returns RevisionSupervisor creada
   */
  async createWithAudit(
    baseData: Omit<Prisma.RevisionSupervisorUncheckedCreateInput, 'version_revision'>,
    casoId: string,
    usuarioId: string,
  ): Promise<RevisionSupervisor> {
    return this.prisma.$transaction(async (tx) => {
      // 1. Marcar anteriores como no vigentes
      await tx.revisionSupervisor.updateMany({
        where: { caso_id: casoId, vigente: true },
        data: { vigente: false },
      });

      // 2. Calcular siguiente versión (dentro de transacción)
      const last = await tx.revisionSupervisor.findFirst({
        where: { caso_id: casoId },
        orderBy: { version_revision: 'desc' },
        select: { version_revision: true },
      });
      const nextVersion = (last?.version_revision ?? 0) + 1;

      // 3. Crear revisión con versión calculada
      const revision = await tx.revisionSupervisor.create({
        data: {
          ...baseData,
          version_revision: nextVersion,
        },
      });

      // 4. Registrar evento de auditoría
      // Nota: resultado siempre EXITOSO porque la operación técnica fue exitosa
      // El resultado funcional (aprobado/devuelto) es dato de negocio, no de auditoría
      await tx.eventoAuditoria.create({
        data: {
          caso_id: casoId,
          usuario_id: usuarioId,
          tipo_evento: TipoEvento.REVISION_SUPERVISOR,
          resultado: ResultadoAuditoria.EXITOSO,
        },
      });

      return revision;
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
