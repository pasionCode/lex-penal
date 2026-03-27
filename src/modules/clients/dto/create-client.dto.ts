import {
  IsString,
  IsOptional,
  IsEnum,
  IsNotEmpty,
  MaxLength,
  ValidateIf,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { SituacionLibertad } from '../../../types/enums';

/**
 * DTO de creación de cliente/procesado.
 * Si detenido, lugar_detencion es obligatorio.
 * Si libre, lugar_detencion se ignora y queda null.
 */
export class CreateClientDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsNotEmpty({ message: 'nombre es requerido' })
  @IsString({ message: 'nombre debe ser texto' })
  @MaxLength(120, { message: 'nombre no puede exceder 120 caracteres' })
  nombre!: string;

  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsNotEmpty({ message: 'tipo_documento es requerido' })
  @IsString({ message: 'tipo_documento debe ser texto' })
  @MaxLength(20, { message: 'tipo_documento no puede exceder 20 caracteres' })
  tipo_documento!: string;

  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsNotEmpty({ message: 'documento es requerido' })
  @IsString({ message: 'documento debe ser texto' })
  @MaxLength(30, { message: 'documento no puede exceder 30 caracteres' })
  documento!: string;

  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'contacto debe ser texto' })
  contacto?: string;

  @IsEnum(SituacionLibertad, {
    message: 'situacion_libertad debe ser: libre, detenido',
  })
  situacion_libertad!: SituacionLibertad;

  @ValidateIf((o) => o.situacion_libertad === SituacionLibertad.DETENIDO)
  @IsNotEmpty({
    message: 'lugar_detencion es requerido si situacion_libertad es detenido',
  })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'lugar_detencion debe ser texto' })
  @MaxLength(200, { message: 'lugar_detencion no puede exceder 200 caracteres' })
  lugar_detencion?: string;
}
