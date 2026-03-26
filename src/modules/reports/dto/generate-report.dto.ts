import { IsEnum } from 'class-validator';
import { TipoInforme, FormatoInforme } from '../../../types/enums';


/**
 * DTO para solicitar generación de informe.
 * POST /api/v1/cases/:caseId/reports
 */
export class GenerateReportDto {
  @IsEnum(TipoInforme, {
    message: 'tipo debe ser uno de: resumen_ejecutivo, conclusion_operativa, control_calidad, riesgos, cronologico, revision_supervisor, agenda_vencimientos',
  })
  tipo!: TipoInforme;

  @IsEnum(FormatoInforme, {
    message: 'formato debe ser: pdf o docx',
  })
  formato!: FormatoInforme;
}
