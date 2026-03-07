import { SituacionLibertad } from '../../../types/enums';

/** Campos actualizables del procesado. */
export class UpdateClientDto {
  nombre?: string;
  tipo_documento?: string;
  documento?: string;
  contacto?: string;
  situacion_libertad?: SituacionLibertad;
  lugar_detencion?: string;
}
