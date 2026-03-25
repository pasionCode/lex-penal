import {
  IsString,
  IsEnum,
  IsOptional,
  IsUUID,
  IsDateString,
  MaxLength,
  ValidateIf,
  IsNotEmpty,
} from 'class-validator';

export enum Probabilidad {
  ALTA = 'alta',
  MEDIA = 'media',
  BAJA = 'baja',
}

export enum Impacto {
  ALTO = 'alto',
  MEDIO = 'medio',
  BAJO = 'bajo',
}

export enum Prioridad {
  CRITICA = 'critica',
  ALTA = 'alta',
  MEDIA = 'media',
  BAJA = 'baja',
}

export enum EstadoMitigacion {
  PENDIENTE = 'pendiente',
  EN_CURSO = 'en_curso',
  MITIGADO = 'mitigado',
  ACEPTADO = 'aceptado',
}

/**
 * DTO para crear un riesgo.
 * POST /api/v1/cases/:caseId/risks
 */
export class CreateRiskDto {
  @IsString({ message: 'descripcion debe ser texto' })
  @MaxLength(2000, { message: 'descripcion no puede exceder 2000 caracteres' })
  descripcion!: string;

  @IsEnum(Probabilidad, {
    message: 'probabilidad debe ser: alta, media o baja',
  })
  probabilidad!: Probabilidad;

  @IsEnum(Impacto, {
    message: 'impacto debe ser: alto, medio o bajo',
  })
  impacto!: Impacto;

  @IsEnum(Prioridad, {
    message: 'prioridad debe ser: critica, alta, media o baja',
  })
  prioridad!: Prioridad;

  @ValidateIf((o) => o.prioridad === Prioridad.CRITICA)
  @IsNotEmpty({ message: 'estrategia_mitigacion es obligatoria para prioridad critica' })
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
