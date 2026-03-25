import { IsOptional, IsString, MaxLength } from 'class-validator';

/**
 * DTO para editar estrategia del caso.
 * PUT /api/v1/cases/:caseId/strategy
 *
 * Nota: linea_principal es obligatorio para transición a pendiente_revision.
 */
export class UpdateStrategyDto {
  @IsOptional()
  @IsString({ message: 'linea_principal debe ser texto' })
  @MaxLength(2000, { message: 'linea_principal no puede exceder 2000 caracteres' })
  linea_principal?: string;

  @IsOptional()
  @IsString({ message: 'fundamento_juridico debe ser texto' })
  @MaxLength(3000, { message: 'fundamento_juridico no puede exceder 3000 caracteres' })
  fundamento_juridico?: string;

  @IsOptional()
  @IsString({ message: 'fundamento_probatorio debe ser texto' })
  @MaxLength(3000, { message: 'fundamento_probatorio no puede exceder 3000 caracteres' })
  fundamento_probatorio?: string;

  @IsOptional()
  @IsString({ message: 'linea_subsidiaria debe ser texto' })
  @MaxLength(2000, { message: 'linea_subsidiaria no puede exceder 2000 caracteres' })
  linea_subsidiaria?: string;

  @IsOptional()
  @IsString({ message: 'posicion_allanamiento debe ser texto' })
  @MaxLength(1000, { message: 'posicion_allanamiento no puede exceder 1000 caracteres' })
  posicion_allanamiento?: string;

  @IsOptional()
  @IsString({ message: 'posicion_preacuerdo debe ser texto' })
  @MaxLength(1000, { message: 'posicion_preacuerdo no puede exceder 1000 caracteres' })
  posicion_preacuerdo?: string;

  @IsOptional()
  @IsString({ message: 'posicion_juicio debe ser texto' })
  @MaxLength(1000, { message: 'posicion_juicio no puede exceder 1000 caracteres' })
  posicion_juicio?: string;
}
