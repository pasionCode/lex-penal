/**
 * Filtros del log de auditoría.
 * tipo: transicion_estado | ia_query | revision_supervisor | informe_generado
 * (valores del modelo, no los stale del contrato anterior).
 */
export class QueryAuditDto {
  tipo?: string;
  page?: number;
  per_page?: number;
}
