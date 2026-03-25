import { IsString, IsDateString, IsOptional, MaxLength } from 'class-validator';

/**
 * DTO para crear evento en línea de tiempo.
 * POST /api/v1/cases/:caseId/timeline
 * 
 * Nota: orden es asignado automáticamente por backend (UNIQUE caso_id + orden).
 */
export class CreateTimelineEntryDto {
  @IsDateString({}, { message: 'fecha_evento debe ser fecha ISO válida' })
  fecha_evento!: string;

  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(1000, { message: 'descripcion no puede exceder 1000 caracteres' })
  descripcion!: string;
}
