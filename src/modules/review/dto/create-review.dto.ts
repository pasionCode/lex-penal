import { IsEnum, IsString, IsNotEmpty, IsOptional, IsDateString, MaxLength } from 'class-validator';

export enum ResultadoRevision {
  APROBADO = 'aprobado',
  DEVUELTO = 'devuelto',
}

/**
 * DTO para crear revisión del supervisor.
 * POST /api/v1/cases/:caseId/review
 */
export class CreateReviewDto {
  @IsEnum(ResultadoRevision, {
    message: 'resultado debe ser: aprobado o devuelto',
  })
  resultado!: ResultadoRevision;

  @IsString({ message: 'observaciones debe ser texto' })
  @IsNotEmpty({ message: 'observaciones es obligatorio' })
  @MaxLength(3000, { message: 'observaciones no puede exceder 3000 caracteres' })
  observaciones!: string;

  @IsOptional()
  @IsDateString({}, { message: 'fecha_revision debe ser fecha ISO válida' })
  fecha_revision?: string;
}
