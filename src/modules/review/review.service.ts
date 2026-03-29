import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { RevisionSupervisor } from '@prisma/client';
import { ReviewRepository } from './review.repository';
import { CreateReviewDto } from './dto/create-review.dto';
import { PerfilUsuario, EstadoCaso } from '../../types/enums';

@Injectable()
export class ReviewService {
  constructor(private readonly repository: ReviewRepository) {}

  /**
   * Retorna historial de revisiones.
   * Solo Supervisor y Admin pueden ver el historial completo.
   */
  async findAll(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<RevisionSupervisor[]> {
    await this.checkCaseExists(casoId);

    if (perfil === PerfilUsuario.ESTUDIANTE) {
      throw new ForbiddenException('Solo supervisores pueden ver el historial de revisiones');
    }

    return this.repository.findByCaseId(casoId);
  }

  /**
   * Retorna feedback (observaciones) de la revisión vigente.
   * Disponible para el estudiante responsable.
   */
  async getFeedback(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<{ observaciones: string; resultado: string; fecha_revision: Date | null } | null> {
    await this.checkCaseExists(casoId);

    // Estudiante solo puede ver feedback de su caso
    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(casoId);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }

    const vigente = await this.repository.findVigente(casoId);
    if (!vigente) {
      return null;
    }

    return {
      observaciones: vigente.observaciones,
      resultado: vigente.resultado,
      fecha_revision: vigente.fecha_revision,
    };
  }

  /**
   * Crea una nueva revisión.
   * Solo Supervisor/Admin, solo en estado pendiente_revision.
   * E6-02: Usa transacción atómica que incluye:
   *   - desvigencia de revisiones anteriores
   *   - cálculo de versión (dentro de transacción, sin race condition)
   *   - creación de revisión
   *   - evento de auditoría
   */
  async create(
    casoId: string,
    dto: CreateReviewDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<RevisionSupervisor> {
    await this.checkCaseExists(casoId);

    // Solo supervisor o admin
    if (perfil === PerfilUsuario.ESTUDIANTE) {
      throw new ForbiddenException('Solo supervisores pueden registrar revisiones');
    }

    // Solo en estado pendiente_revision
    const estado = await this.repository.getCaseState(casoId);
    if (estado !== EstadoCaso.PENDIENTE_REVISION) {
      throw new ConflictException(
        `Solo se puede revisar en estado pendiente_revision. Estado actual: ${estado}`,
      );
    }

    // E6-02: Operación atómica completa
    // version_revision se calcula dentro de la transacción
    return this.repository.createWithAudit(
      {
        caso_id: casoId,
        supervisor_id: userId,
        vigente: true,
        observaciones: dto.observaciones,
        resultado: dto.resultado,
        fecha_revision: dto.fecha_revision ? new Date(dto.fecha_revision) : new Date(),
        creado_por: userId,
      },
      casoId,
      userId,
    );
  }

  private async checkCaseExists(casoId: string): Promise<void> {
    const exists = await this.repository.caseExists(casoId);
    if (!exists) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }
  }
}
