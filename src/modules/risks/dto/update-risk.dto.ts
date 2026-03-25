import {
  IsString,
  IsEnum,
  IsOptional,
  IsUUID,
  IsDateString,
  MaxLength,
} from 'class-validator';
import {
  Probabilidad,
  Impacto,
  Prioridad,
  EstadoMitigacion,
} from './create-risk.dto';

/**
 * DTO para editar un riesgo.
 * PUT /api/v1/cases/:caseId/risks/:riskId
 */
export class UpdateRiskDto {
  @IsOptional()
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(2000, { message: 'descripcion no puede exceder 2000 caracteres' })
  descripcion?: string;

  @IsOptional()
  @IsEnum(Probabilidad, {
    message: 'probabilidad debe ser: alta, media o baja',
  })
  probabilidad?: Probabilidad;

  @IsOptional()
  @IsEnum(Impacto, {
    message: 'impacto debe ser: alto, medio o bajo',
  })
  impacto?: Impacto;

  @IsOptional()
  @IsEnum(Prioridad, {
    message: 'prioridad debe ser: critica, alta, media o baja',
  })
  prioridad?: Prioridad;

  @IsOptional()
  @IsString({ message: 'estrategia_mitigacion debe ser texto' })
  @MaxLength(2000, { message: 'estrategia_mitigacion no puede exceder 2000 caracteres' })
  estrategia_mitigacion?: string;

  @IsOptional()
  @IsEnum(EstadoMitigacion, {
    message: 'estado_mitigacion debe ser: pendiente, en_curso, mitigado o aceptado',
  })
  estado_mitigacion?: EstadoMitigacion;

  @IsOptional()
  @IsDateString({}, { message: 'plazo_accion debe ser fecha ISO válida' })
  plazo_accion?: string;

  @IsOptional()
  @IsUUID('4', { message: 'responsable_id debe ser un UUID válido' })
  responsable_id?: string;
}
