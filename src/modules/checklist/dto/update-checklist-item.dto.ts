/** Actualización de estado de uno o varios ítems del checklist. */
export class ChecklistItemUpdateDto {
  id!: string;
  marcado!: boolean;
}

export class UpdateChecklistDto {
  items!: ChecklistItemUpdateDto[];
}
