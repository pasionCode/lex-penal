import { IsOptional, IsInt, Min, Max, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';
import { TipoSujeto } from './create-subject.dto';

export class ListSubjectsQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'page debe ser entero' })
  @Min(1, { message: 'page debe ser >= 1' })
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'per_page debe ser entero' })
  @Min(1, { message: 'per_page debe ser >= 1' })
  @Max(100, { message: 'per_page no puede exceder 100' })
  per_page?: number = 20;

  @IsOptional()
  @IsEnum(TipoSujeto, {
    message: 'tipo debe ser: victima, imputado, testigo, apoderado, otro',
  })
  tipo?: TipoSujeto;
}
