import { IsOptional, IsString, IsDateString, MaxLength } from 'class-validator';

/**
 * DTO para actualizar explicación al cliente.
 * PUT /api/v1/cases/:caseId/client-briefing
 */
export class UpdateClientBriefingDto {
  @IsOptional()
  @IsString({ message: 'delito_explicado debe ser texto' })
  @MaxLength(2000, { message: 'delito_explicado no puede exceder 2000 caracteres' })
  delito_explicado?: string;

  @IsOptional()
  @IsString({ message: 'riesgos_informados debe ser texto' })
  @MaxLength(2000, { message: 'riesgos_informados no puede exceder 2000 caracteres' })
  riesgos_informados?: string;

  @IsOptional()
  @IsString({ message: 'panorama_probatorio debe ser texto' })
  @MaxLength(2000, { message: 'panorama_probatorio no puede exceder 2000 caracteres' })
  panorama_probatorio?: string;

  @IsOptional()
  @IsString({ message: 'beneficios_informados debe ser texto' })
  @MaxLength(2000, { message: 'beneficios_informados no puede exceder 2000 caracteres' })
  beneficios_informados?: string;

  @IsOptional()
  @IsString({ message: 'opciones_explicadas debe ser texto' })
  @MaxLength(2000, { message: 'opciones_explicadas no puede exceder 2000 caracteres' })
  opciones_explicadas?: string;

  @IsOptional()
  @IsString({ message: 'recomendacion debe ser texto' })
  @MaxLength(2000, { message: 'recomendacion no puede exceder 2000 caracteres' })
  recomendacion?: string;

  @IsOptional()
  @IsString({ message: 'decision_cliente debe ser texto' })
  @MaxLength(1000, { message: 'decision_cliente no puede exceder 1000 caracteres' })
  decision_cliente?: string;

  @IsOptional()
  @IsDateString({}, { message: 'fecha_explicacion debe ser fecha ISO válida' })
  fecha_explicacion?: string;
}
