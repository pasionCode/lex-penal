import {
  IsString,
  IsEnum,
  IsOptional,
  MaxLength,
} from 'class-validator';
import { EstadoHecho, IncidenciaJuridica } from '../../../types/enums';

/**
 * DTO para editar un hecho.
 * PUT /api/v1/cases/:caseId/facts/:factId
 *
 * Nota: `orden` no es editable por el cliente.
 */
export class UpdateFactDto {
  @IsOptional()
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(2000, { message: 'descripcion no puede exceder 2000 caracteres' })
  descripcion?: string;

  @IsOptional()
  @IsEnum(EstadoHecho, {
    message: 'estado_hecho debe ser: acreditado, referido o discutido',
  })
  estado_hecho?: EstadoHecho;

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
