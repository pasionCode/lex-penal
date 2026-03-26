import {
  IsString,
  IsOptional,
  MaxLength,
} from 'class-validator';

/**
 * DTO para actualizar un documento.
 * PUT /api/v1/cases/:caseId/documents/:documentId
 * 
 * Política Sprint 11: Solo el campo `descripcion` es editable.
 * Los demás campos permanecen inmutables (append-only estructural).
 */
export class UpdateDocumentDto {
  @IsOptional()
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(1000, { message: 'descripcion no puede exceder 1000 caracteres' })
  descripcion?: string;
}
