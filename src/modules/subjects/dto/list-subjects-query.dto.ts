import {Transform, Type} from 'class-transformer';
import {IsEnum, IsInt, IsNotEmpty, IsOptional, IsString, Max, Min} from 'class-validator';
import { TipoIdentificacion, TipoSujeto } from '@prisma/client';

export class ListSubjectsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  per_page: number = 20;

  @IsOptional()
  @IsEnum(TipoSujeto)
  tipo?: TipoSujeto;

  @IsOptional()
  @Transform(({ value }) => {
    if (typeof value !== 'string') return value;
    return value.trim();
  })
  @IsString()
  @IsNotEmpty()
  nombre?: string;

  @IsOptional()
  @Transform(({ value }) => {
    if (typeof value !== 'string') return value;
    return value.trim();
  })
  @IsString()
  @IsNotEmpty()
  identificacion?: string;

  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim() : value,
  )
  @IsEnum(TipoIdentificacion, {
    message: 'tipo_identificacion debe ser: CC, TI, CE, PAS, NIT, otro',
  })
  @IsNotEmpty()
  tipo_identificacion?: TipoIdentificacion;

}
