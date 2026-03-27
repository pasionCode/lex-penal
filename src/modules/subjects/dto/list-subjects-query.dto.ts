import { Transform, Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { TipoSujeto } from '@prisma/client';

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
}
