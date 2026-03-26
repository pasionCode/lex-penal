import { IsEnum, IsString, IsUUID, IsNotEmpty, MaxLength } from 'class-validator';
import { HerramientaIA } from '../../../types/enums';


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
