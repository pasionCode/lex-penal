import { IsEnum } from 'class-validator';

export enum TipoInforme {
  RESUMEN_EJECUTIVO = 'resumen_ejecutivo',
  CONCLUSION_OPERATIVA = 'conclusion_operativa',
  CONTROL_CALIDAD = 'control_calidad',
  RIESGOS = 'riesgos',
  CRONOLOGICO = 'cronologico',
  REVISION_SUPERVISOR = 'revision_supervisor',
  AGENDA_VENCIMIENTOS = 'agenda_vencimientos',
}

export enum FormatoInforme {
  PDF = 'pdf',
  DOCX = 'docx',
}

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
