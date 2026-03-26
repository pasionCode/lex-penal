import {
  IsString,
  IsEnum,
  IsOptional,
  IsInt,
  Min,
  MaxLength,
  IsNotEmpty,
} from 'class-validator';
import { CategoriaDocumento } from '../../../types/enums';

/**
 * DTO para registrar metadatos de un documento.
 * POST /api/v1/cases/:caseId/documents
 *
 * Nota: Sprint 10 solo registra metadatos, sin subida real de archivos.
 * Sprint 12: Hardening de validaciones.
 */
export class CreateDocumentDto {
  @IsEnum(CategoriaDocumento, {
    message: 'categoria debe ser: acusacion, defensa, cliente, actuacion, informe, evidencia, anexo u otro',
  })
  categoria!: CategoriaDocumento;

  @IsNotEmpty({ message: 'nombre_original es requerido' })
  @IsString({ message: 'nombre_original debe ser texto' })
  @MaxLength(255, { message: 'nombre_original no puede exceder 255 caracteres' })
  nombre_original!: string;

  @IsNotEmpty({ message: 'nombre_almacenado es requerido' })
  @IsString({ message: 'nombre_almacenado debe ser texto' })
  @MaxLength(255, { message: 'nombre_almacenado no puede exceder 255 caracteres' })
  nombre_almacenado!: string;

  @IsNotEmpty({ message: 'ruta es requerido' })
  @IsString({ message: 'ruta debe ser texto' })
  @MaxLength(500, { message: 'ruta no puede exceder 500 caracteres' })
  ruta!: string;

  @IsNotEmpty({ message: 'mime_type es requerido' })
  @IsString({ message: 'mime_type debe ser texto' })
  @MaxLength(100, { message: 'mime_type no puede exceder 100 caracteres' })
  mime_type!: string;

  @IsInt({ message: 'tamanio_bytes debe ser entero' })
  @Min(1, { message: 'tamanio_bytes debe ser mayor a cero' })
  tamanio_bytes!: number;

  @IsOptional()
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(1000, { message: 'descripcion no puede exceder 1000 caracteres' })
  descripcion?: string;
}
