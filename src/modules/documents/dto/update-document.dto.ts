import {
  IsString,
  IsOptional,
  MaxLength,
} from 'class-validator';

/**
 * DTO para actualización limitada de un documento referenciado.
 * PUT /api/v1/cases/:caseId/documents/:documentId
 *
 * Política vigente: solo el campo `descripcion` es editable.
 * No hay reemplazo de archivo ni modificación de ruta, mime_type,
 * nombre_original, nombre_almacenado o tamanio_bytes.
 */
export class UpdateDocumentDto {
  @IsOptional()
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(1000, { message: 'descripcion no puede exceder 1000 caracteres' })
  descripcion?: string;
}
