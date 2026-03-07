import { EstadoMitigacion, Impacto, Prioridad, Probabilidad } from '../../../types/enums';

export class RiskItemDto {
  descripcion!: string;
  probabilidad!: Probabilidad;
  impacto!: Impacto;
  prioridad!: Prioridad;
  estrategia_mitigacion?: string;
  estado_mitigacion!: EstadoMitigacion;
  plazo_accion?: string;
  responsable_id?: string;
}

export class UpdateRisksDto {
  riesgos!: RiskItemDto[];
}
