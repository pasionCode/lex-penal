import { IsEnum, IsString, IsUUID, IsNotEmpty, MaxLength } from 'class-validator';

export enum HerramientaIA {
  BASIC_INFO = 'basic_info',
  FACTS = 'facts',
  EVIDENCE = 'evidence',
  RISKS = 'risks',
  STRATEGY = 'strategy',
  CLIENT_BRIEFING = 'client_briefing',
  CHECKLIST = 'checklist',
  CONCLUSION = 'conclusion',
}

/**
 * DTO para consulta IA.
 * POST /api/v1/ai/query
 */
export class AIQueryDto {
  @IsUUID('4', { message: 'caso_id debe ser UUID válido' })
  caso_id!: string;

  @IsEnum(HerramientaIA, {
    message: 'herramienta debe ser: basic_info, facts, evidence, risks, strategy, client_briefing, checklist, conclusion',
  })
  herramienta!: HerramientaIA;

  @IsString({ message: 'consulta debe ser texto' })
  @IsNotEmpty({ message: 'consulta es obligatoria' })
  @MaxLength(2000, { message: 'consulta no puede exceder 2000 caracteres' })
  consulta!: string;
}
