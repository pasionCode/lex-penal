import { HerramientaIA } from '../../../types/enums';

/**
 * Body de POST /api/v1/ai/query.
 * herramienta debe ser uno de los 8 valores canónicos (HerramientaIA enum).
 * Cualquier otro valor retorna 422.
 */
export class AIQueryDto {
  caso_id!: string;
  herramienta!: HerramientaIA;
  consulta!: string;
}
