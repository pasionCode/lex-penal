import { IsOptional, IsInt, Min, Max, IsIn } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Valores válidos de tipo de evento para filtrar.
 * Debe coincidir con enum TipoEvento de Prisma.
 */
export const TIPOS_EVENTO_VALIDOS = [
  'transicion_estado',
  'informe_generado',
  'revision_supervisor',
  'login',
  'logout',
  'eliminacion_caso',
  'ia_query',
] as const;

export type TipoEventoFiltro = typeof TIPOS_EVENTO_VALIDOS[number];

/**
 * Filtros del log de auditoría.
 * GET /api/v1/cases/{caseId}/audit
 */
export class QueryAuditDto {
  @IsOptional()
  @IsIn(TIPOS_EVENTO_VALIDOS, {
    message: `tipo debe ser uno de: ${TIPOS_EVENTO_VALIDOS.join(', ')}`,
  })
  tipo?: TipoEventoFiltro;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  per_page?: number = 20;
}
