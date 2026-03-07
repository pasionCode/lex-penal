/**
 * Cinco bloques de conclusion_operativa (MODELO_DATOS_v3).
 * Todos opcionales — PUT actualiza solo los enviados.
 */
export class UpdateConclusionDto {
  // Bloque 1 — Síntesis jurídica
  hechos_sintesis?: string;
  cargo_imputado?: string;
  evaluacion_dogmatica?: string;
  fisuras_fortalezas?: string;
  // Bloque 2 — Panorama procesal
  fortalezas_acusacion?: string;
  debilidades_acusacion?: string;
  prueba_defensa?: string;
  etapa_texto?: string;
  oportunidades?: string;
  // Bloque 3 — Dosimetría y beneficios
  rangos_pena?: string;
  beneficios?: string;
  restricciones_subrogados?: string;
  riesgos_prioritarios?: string;
  // Bloque 4 — Opciones
  opcion_a?: string; consecuencias_a?: string;
  opcion_b?: string; consecuencias_b?: string;
  opcion_c?: string; consecuencias_c?: string;
  // Bloque 5 — Recomendación (obligatorio para listo_para_cliente)
  recomendacion?: string;
  fundamento_recomendacion?: string;
  condicion_vigencia?: string;
  // Adicional
  observaciones?: string;
}
