import {
  IsString,
  IsEnum,
  IsOptional,
  MaxLength,
} from 'class-validator';
import { EstadoHecho, IncidenciaJuridica } from '../../../types/enums';


/**
 * DTO para crear un hecho.
 * POST /api/v1/cases/:caseId/facts
 *
 * Nota: `orden` es asignado automáticamente por el backend.
 */
export class CreateFactDto {
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(2000, { message: 'descripcion no puede exceder 2000 caracteres' })
  descripcion!: string;

  @IsEnum(EstadoHecho, {
    message: 'estado_hecho debe ser: acreditado, referido o discutido',
  })
  estado_hecho!: EstadoHecho;

  @IsOptional()
  @IsString({ message: 'fuente debe ser texto' })
  @MaxLength(500, { message: 'fuente no puede exceder 500 caracteres' })
  fuente?: string;

  @IsOptional()
  @IsEnum(IncidenciaJuridica, {
    message: 'incidencia_juridica debe ser: tipicidad, antijuridicidad, culpabilidad o procedimiento',
  })
  incidencia_juridica?: IncidenciaJuridica;
}
