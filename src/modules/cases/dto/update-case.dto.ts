import {
  IsOptional,
  IsString,
  IsIn,
  IsDateString,
  MaxLength,
} from 'class-validator';

/**
 * DTO para actualizar metadata editable del caso.
 * PUT /api/v1/cases/:id
 *
 * Solo permitido en estados: en_analisis, devuelto.
 * Campos inmutables (ignorados por diseño, rechazados por ValidationPipe):
 * - estado_actual, responsable_id, creado_por, creado_en, cliente_id, radicado, delito_imputado
 */
export class UpdateCaseDto {
  @IsOptional()
  @IsString({ message: 'despacho debe ser texto' })
  @MaxLength(200, { message: 'despacho no puede exceder 200 caracteres' })
  despacho?: string;

  @IsOptional()
  @IsString({ message: 'etapa_procesal debe ser texto' })
  @MaxLength(100, { message: 'etapa_procesal no puede exceder 100 caracteres' })
  etapa_procesal?: string;

  @IsOptional()
  @IsString({ message: 'regimen_procesal debe ser texto' })
  @IsIn(['Ley 600', 'Ley 906'], {
    message: 'regimen_procesal debe ser Ley 600 o Ley 906',
  })
  regimen_procesal?: string;

  @IsOptional()
  @IsString({ message: 'proxima_actuacion debe ser texto' })
  @MaxLength(200, {
    message: 'proxima_actuacion no puede exceder 200 caracteres',
  })
  proxima_actuacion?: string;

  @IsOptional()
  @IsDateString({}, { message: 'fecha_proxima_actuacion debe ser fecha ISO válida' })
  fecha_proxima_actuacion?: string;

  @IsOptional()
  @IsString({ message: 'responsable_proxima_actuacion debe ser texto' })
  @MaxLength(120, {
    message: 'responsable_proxima_actuacion no puede exceder 120 caracteres',
  })
  responsable_proxima_actuacion?: string;

  @IsOptional()
  @IsString({ message: 'observaciones debe ser texto' })
  @MaxLength(2000, { message: 'observaciones no puede exceder 2000 caracteres' })
  observaciones?: string;

  @IsOptional()
  @IsString({ message: 'agravantes debe ser texto' })
  @MaxLength(500, { message: 'agravantes no puede exceder 500 caracteres' })
  agravantes?: string;
}
