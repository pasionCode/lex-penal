import {
  IsString,
  IsEnum,
  IsOptional,
  MaxLength,
} from 'class-validator';
import { TipoPrueba, EvaluacionProbatoria } from '../../../types/enums';

/**
 * DTO para editar una prueba.
 * PUT /api/v1/cases/:caseId/evidence/:evidenceId
 *
 * Nota: hecho_id se gestiona via /link y /unlink
 */
export class UpdateEvidenceDto {
  @IsOptional()
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(2000, { message: 'descripcion no puede exceder 2000 caracteres' })
  descripcion?: string;

  @IsOptional()
  @IsEnum(TipoPrueba, {
    message: 'tipo_prueba debe ser: testimonial, documental, pericial, real u otro',
  })
  tipo_prueba?: TipoPrueba;

  @IsOptional()
  @IsString({ message: 'hecho_descripcion_libre debe ser texto' })
  @MaxLength(500, { message: 'hecho_descripcion_libre no puede exceder 500 caracteres' })
  hecho_descripcion_libre?: string;

  @IsOptional()
  @IsEnum(EvaluacionProbatoria, {
    message: 'licitud debe ser: ok, cuestionable o deficiente',
  })
  licitud?: EvaluacionProbatoria;

  @IsOptional()
  @IsEnum(EvaluacionProbatoria, {
    message: 'legalidad debe ser: ok, cuestionable o deficiente',
  })
  legalidad?: EvaluacionProbatoria;

  @IsOptional()
  @IsEnum(EvaluacionProbatoria, {
    message: 'suficiencia debe ser: ok, cuestionable o deficiente',
  })
  suficiencia?: EvaluacionProbatoria;

  @IsOptional()
  @IsEnum(EvaluacionProbatoria, {
    message: 'credibilidad debe ser: ok, cuestionable o deficiente',
  })
  credibilidad?: EvaluacionProbatoria;

  @IsOptional()
  @IsString({ message: 'posicion_defensiva debe ser texto' })
  @MaxLength(1000, { message: 'posicion_defensiva no puede exceder 1000 caracteres' })
  posicion_defensiva?: string;
}
