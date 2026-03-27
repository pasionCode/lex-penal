import {
  IsString,
  IsOptional,
  IsEnum,
  MaxLength,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { SituacionLibertad } from '../../../types/enums';

/**
 * DTO de actualización de cliente/procesado.
 * La validación de lugar_detencion se hace en el service
 * considerando el estado resultante (DTO + estado actual).
 */
export class UpdateClientDto {
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'nombre debe ser texto' })
  @MaxLength(120, { message: 'nombre no puede exceder 120 caracteres' })
  nombre?: string;

  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'tipo_documento debe ser texto' })
  @MaxLength(20, { message: 'tipo_documento no puede exceder 20 caracteres' })
  tipo_documento?: string;

  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'documento debe ser texto' })
  @MaxLength(30, { message: 'documento no puede exceder 30 caracteres' })
  documento?: string;

  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'contacto debe ser texto' })
  contacto?: string;

  @IsOptional()
  @IsEnum(SituacionLibertad, {
    message: 'situacion_libertad debe ser: libre, detenido',
  })
  situacion_libertad?: SituacionLibertad;

  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString({ message: 'lugar_detencion debe ser texto' })
  @MaxLength(200, { message: 'lugar_detencion no puede exceder 200 caracteres' })
  lugar_detencion?: string;
}
