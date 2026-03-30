import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { ExplicacionCliente } from '@prisma/client';
import { ClientBriefingRepository } from './client-briefing.repository';
import { UpdateClientBriefingDto } from './dto/update-client-briefing.dto';
import { PerfilUsuario, EstadoCaso } from '../../types/enums';

/**
 * E6-03: Estados que permiten escritura en client-briefing.
 * Excepción controlada: incluye listo_para_cliente porque
 * decision_cliente debe documentarse antes del cierre.
 */
const ESTADOS_ESCRITURA_PERMITIDA_CLIENT_BRIEFING: EstadoCaso[] = [
  EstadoCaso.EN_ANALISIS,
  EstadoCaso.DEVUELTO,
  EstadoCaso.LISTO_PARA_CLIENTE,
];

@Injectable()
export class ClientBriefingService {
  constructor(private readonly repository: ClientBriefingRepository) {}

  /**
   * Obtiene la explicación al cliente del caso.
   * E7-04: Si no existe, valida estado antes de auto-crear.
   * - Estado permitido + no existe → auto-crea → 200
   * - Estado permitido + existe → retorna → 200
   * - Estado no permitido + existe → retorna → 200 (lectura permitida)
   * - Estado no permitido + no existe → 409
   */
  async findByCaseId(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<ExplicacionCliente> {
    await this.checkCaseAccess(casoId, userId, perfil);

    let briefing = await this.repository.findByCaseId(casoId);

    if (!briefing) {
      // E7-04: Validar estado antes de auto-crear
      await this.checkWritePermission(casoId);

      briefing = await this.repository.create({
        caso_id: casoId,
        creado_por: userId,
      });
    }

    return briefing;
  }

  async update(
    casoId: string,
    dto: UpdateClientBriefingDto,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<ExplicacionCliente> {
    await this.checkCaseAccess(casoId, userId, perfil);

    // E6-03: Validar estado del caso antes de permitir escritura
    await this.checkWritePermission(casoId);

    let briefing = await this.repository.findByCaseId(casoId);

    if (!briefing) {
      return this.repository.create({
        caso_id: casoId,
        delito_explicado: dto.delito_explicado ?? null,
        riesgos_informados: dto.riesgos_informados ?? null,
        panorama_probatorio: dto.panorama_probatorio ?? null,
        beneficios_informados: dto.beneficios_informados ?? null,
        opciones_explicadas: dto.opciones_explicadas ?? null,
        recomendacion: dto.recomendacion ?? null,
        decision_cliente: dto.decision_cliente ?? null,
        fecha_explicacion: dto.fecha_explicacion ? new Date(dto.fecha_explicacion) : null,
        creado_por: userId,
        actualizado_por: userId,
      });
    }

    const updateData: Record<string, unknown> = {
      actualizado_por: userId,
    };

    if (dto.delito_explicado !== undefined) updateData.delito_explicado = dto.delito_explicado;
    if (dto.riesgos_informados !== undefined) updateData.riesgos_informados = dto.riesgos_informados;
    if (dto.panorama_probatorio !== undefined) updateData.panorama_probatorio = dto.panorama_probatorio;
    if (dto.beneficios_informados !== undefined) updateData.beneficios_informados = dto.beneficios_informados;
    if (dto.opciones_explicadas !== undefined) updateData.opciones_explicadas = dto.opciones_explicadas;
    if (dto.recomendacion !== undefined) updateData.recomendacion = dto.recomendacion;
    if (dto.decision_cliente !== undefined) updateData.decision_cliente = dto.decision_cliente;
    if (dto.fecha_explicacion !== undefined) updateData.fecha_explicacion = new Date(dto.fecha_explicacion);

    return this.repository.update(casoId, updateData);
  }

  private async checkCaseAccess(
    casoId: string,
    userId: string,
    perfil: PerfilUsuario,
  ): Promise<void> {
    const exists = await this.repository.caseExists(casoId);
    if (!exists) {
      throw new NotFoundException(`Caso ${casoId} no encontrado`);
    }

    if (perfil === PerfilUsuario.ESTUDIANTE) {
      const responsable = await this.repository.getCaseResponsable(casoId);
      if (responsable !== userId) {
        throw new ForbiddenException('Sin acceso a este caso');
      }
    }
  }

  /**
   * E6-03: Valida que el estado del caso permita escritura en client-briefing.
   * Política específica: permite en_analisis, devuelto y listo_para_cliente.
   * Bloquea en borrador, pendiente_revision, aprobado_supervisor y cerrado.
   *
   * @throws ConflictException (409) si el estado no permite escritura
   */
  private async checkWritePermission(casoId: string): Promise<void> {
    const estado = await this.repository.getCaseState(casoId);

    if (!estado || !ESTADOS_ESCRITURA_PERMITIDA_CLIENT_BRIEFING.includes(estado as EstadoCaso)) {
      throw new ConflictException(
        `No se permite modificar client-briefing en estado ${estado ?? 'desconocido'}`,
      );
    }
  }
}
