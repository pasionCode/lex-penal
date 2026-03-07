import { FormatoInforme, TipoInforme } from '../../../types/enums';

/** Solicitud de generación de informe (CATALOGO_INFORMES.md). */
export class GenerateReportDto {
  tipo!: TipoInforme;
  formato!: FormatoInforme;
}
