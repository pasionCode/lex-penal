import { EstadoCaso } from '../../../types/enums';

/**
 * DTO de transición de estado.
 * 409: la transición no existe desde el estado actual.
 * 422: la transición existe pero falla una guarda de negocio.
 */
export class TransitionStateDto {
  estado_destino!: EstadoCaso;
  observaciones?: string;
}
