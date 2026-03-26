import {
  IsString,
  IsOptional,
  IsUUID,
  IsBoolean,
  IsDateString,
  MaxLength,
} from 'class-validator';

/**
 * DTO para editar una actuación procesal.
 * PUT /api/v1/cases/:caseId/proceedings/:proceedingId
 */
export class UpdateProceedingDto {
  @IsOptional()
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(1000, { message: 'descripcion no puede exceder 1000 caracteres' })
  descripcion?: string;

  @IsOptional()
  @IsDateString({}, { message: 'fecha debe ser fecha ISO válida' })
  fecha?: string;

  @IsOptional()
  @IsUUID('4', { message: 'responsable_id debe ser UUID válido' })
  responsable_id?: string;

  @IsOptional()
  @IsString({ message: 'responsable_externo debe ser texto' })
  @MaxLength(120, { message: 'responsable_externo no puede exceder 120 caracteres' })
  responsable_externo?: string;

  @IsOptional()
  @IsBoolean({ message: 'completada debe ser booleano' })
  completada?: boolean;
}
