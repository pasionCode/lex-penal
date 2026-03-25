import { IsOptional, IsString, MaxLength } from 'class-validator';

/**
 * DTO para actualizar conclusión operativa.
 * PUT /api/v1/cases/:caseId/conclusion
 */
export class UpdateConclusionDto {
  // Bloque 1 — Síntesis jurídica
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  hechos_sintesis?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  cargo_imputado?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  evaluacion_dogmatica?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  fisuras_fortalezas?: string;

  // Bloque 2 — Panorama procesal
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  fortalezas_acusacion?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  debilidades_acusacion?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  prueba_defensa?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  etapa_texto?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  oportunidades?: string;

  // Bloque 3 — Dosimetría y beneficios
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  rangos_pena?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  beneficios?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  restricciones_subrogados?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  riesgos_prioritarios?: string;

  // Bloque 4 — Opciones
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  opcion_a?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  consecuencias_a?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  opcion_b?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  consecuencias_b?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  opcion_c?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  consecuencias_c?: string;

  // Bloque 5 — Recomendación
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  recomendacion?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  fundamento_recomendacion?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  condicion_vigencia?: string;

  // Adicional
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  observaciones?: string;
}