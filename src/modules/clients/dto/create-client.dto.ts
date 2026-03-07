import { SituacionLibertad } from '../../../types/enums';

/**
 * DTO de creación de cliente/procesado.
 * situacion_libertad en clientes, NO en client-briefing (MODELO_DATOS_v3).
 * Si detenido, lugar_detencion es obligatorio.
 */
export class CreateClientDto {
  nombre!: string;
  tipo_documento!: string;
  documento!: string;
  contacto?: string;
  situacion_libertad!: SituacionLibertad;
  lugar_detencion?: string;
}
