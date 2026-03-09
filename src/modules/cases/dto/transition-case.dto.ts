/**
 * DTO para solicitar transición de estado del caso.
 * Fuente: ADR-003, endpoint POST /api/v1/cases/{id}/transition
 */

import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { EstadoCaso } from '../../../types/enums';

export class TransitionCaseDto {
  /**
   * Estado destino de la transición.
   */
  @IsEnum(EstadoCaso, {
    message: 'estado_destino debe ser un estado válido del caso',
  })
  estado_destino: EstadoCaso;

  /**
   * Observaciones del supervisor.
   * Requerido para transiciones:
   * - pendiente_revision → devuelto
   * - pendiente_revision → aprobado_supervisor
   */
  @IsOptional()
  @IsString()
  @MaxLength(5000, {
    message: 'Las observaciones no pueden exceder 5000 caracteres',
  })
  observaciones?: string;
}
