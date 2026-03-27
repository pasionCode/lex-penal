import {
  IsString,
  IsOptional,
  IsEnum,
  IsNotEmpty,
  MaxLength,
} from 'class-validator';
import { Transform } from 'class-transformer';

export enum TipoSujeto {
  victima = 'victima',
  imputado = 'imputado',
  testigo = 'testigo',
  apoderado = 'apoderado',
  otro = 'otro',
}

export enum TipoIdentificacion {
  CC = 'CC',
  TI = 'TI',
  CE = 'CE',
  PAS = 'PAS',
  NIT = 'NIT',
  otro = 'otro',
}

export class CreateSubjectDto {
  @IsEnum(TipoSujeto, { message: 'tipo debe ser: victima, imputado, testigo, apoderado, otro' })
  tipo!: TipoSujeto;

  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @IsNotEmpty({ message: 'nombre es requerido' })
  @IsString({ message: 'nombre debe ser texto' })
  @MaxLength(120, { message: 'nombre no puede exceder 120 caracteres' })
  nombre!: string;

  @IsOptional()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @IsString({ message: 'identificacion debe ser texto' })
  @MaxLength(40, { message: 'identificacion no puede exceder 40 caracteres' })
  identificacion?: string;

  @IsOptional()
  @IsEnum(TipoIdentificacion, { message: 'tipo_identificacion debe ser: CC, TI, CE, PAS, NIT, otro' })
  tipo_identificacion?: TipoIdentificacion;

  @IsOptional()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @IsString({ message: 'contacto debe ser texto' })
  @MaxLength(120, { message: 'contacto no puede exceder 120 caracteres' })
  contacto?: string;

  @IsOptional()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @IsString({ message: 'direccion debe ser texto' })
  @MaxLength(255, { message: 'direccion no puede exceder 255 caracteres' })
  direccion?: string;

  @IsOptional()
  @Transform(({ value }) => typeof value === 'string' ? value.trim() : value)
  @IsString({ message: 'notas debe ser texto' })
  notas?: string;
}
