import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import { EstadoCaso } from '../../../types/enums';

/**
 * DTO de transición de estado.
 * POST /api/v1/cases/:id/transition
 *
 * 409: la transición no existe desde el estado actual.
 * 422: la transición existe pero falla una guarda de negocio.
 */
export class TransitionStateDto {
  @IsEnum(EstadoCaso, {
    message: `estado_destino debe ser uno de: ${Object.values(EstadoCaso).join(', ')}`,
  })
  estado_destino!: EstadoCaso;

  @IsOptional()
  @IsString({ message: 'observaciones debe ser texto' })
  @MaxLength(500, { message: 'observaciones no puede exceder 500 caracteres' })
  observaciones?: string;
}