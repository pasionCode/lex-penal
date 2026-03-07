import { ResultadoRevision } from '../../../types/enums';

/**
 * Registro formal de revisión del supervisor.
 * observaciones no puede estar vacío (R04, MODELO_DATOS_v3 — revision_supervisor).
 */
export class CreateReviewDto {
  resultado!: ResultadoRevision;
  observaciones!: string;
  fecha_revision?: string;
}
