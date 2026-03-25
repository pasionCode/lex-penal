import { IsArray, IsBoolean, IsUUID, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * Actualización de estado de un ítem del checklist.
 */
export class ChecklistItemUpdateDto {
  @IsUUID('4', { message: 'id debe ser UUID válido' })
  id!: string;

  @IsBoolean({ message: 'marcado debe ser booleano' })
  marcado!: boolean;
}

/**
 * DTO para actualizar múltiples ítems del checklist.
 * PUT /api/v1/cases/:caseId/checklist
 */
export class UpdateChecklistDto {
  @IsArray({ message: 'items debe ser un array' })
  @ValidateNested({ each: true })
  @Type(() => ChecklistItemUpdateDto)
  items!: ChecklistItemUpdateDto[];
}
