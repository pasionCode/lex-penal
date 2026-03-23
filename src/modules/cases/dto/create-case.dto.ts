import {
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  IsDateString,
  IsIn,
  MaxLength,
} from 'class-validator';

/**
 * DTO para crear un caso.
 * POST /api/v1/cases
 *
 * Campos obligatorios alineados con guarda borrador→en_analisis (ADR-003).
 * responsable_id, creado_por, actualizado_por se asignan desde el usuario autenticado.
 */
export class CreateCaseDto {
  @IsUUID('4', { message: 'cliente_id debe ser un UUID válido' })
  @IsNotEmpty({ message: 'cliente_id es obligatorio' })
  cliente_id!: string;

  @IsString({ message: 'radicado debe ser texto' })
  @IsNotEmpty({ message: 'radicado es obligatorio' })
  @MaxLength(80, { message: 'radicado no puede exceder 80 caracteres' })
  radicado!: string;

  @IsString({ message: 'delito_imputado debe ser texto' })
  @IsNotEmpty({ message: 'delito_imputado es obligatorio' })
  @MaxLength(300, { message: 'delito_imputado no puede exceder 300 caracteres' })
  delito_imputado!: string;

  @IsString({ message: 'regimen_procesal debe ser texto' })
  @IsNotEmpty({ message: 'regimen_procesal es obligatorio' })
  @IsIn(['Ley 600', 'Ley 906'], {
    message: 'regimen_procesal debe ser Ley 600 o Ley 906',
  })
  regimen_procesal!: string;

  @IsString({ message: 'etapa_procesal debe ser texto' })
  @IsNotEmpty({ message: 'etapa_procesal es obligatorio' })
  @MaxLength(100, { message: 'etapa_procesal no puede exceder 100 caracteres' })
  etapa_procesal!: string;

  @IsOptional()
  @IsString({ message: 'despacho debe ser texto' })
  @MaxLength(200, { message: 'despacho no puede exceder 200 caracteres' })
  despacho?: string;

  @IsOptional()
  @IsDateString({}, { message: 'fecha_apertura debe ser una fecha ISO válida' })
  fecha_apertura?: string;
}
