/** Campos actualizables del caso (basic-info y metadata). */
export class UpdateCaseDto {
  despacho?: string;
  etapa_procesal?: string;
  regimen_procesal?: string;
  proxima_actuacion?: string;
  fecha_proxima_actuacion?: string;
  responsable_proxima_actuacion?: string;
  observaciones?: string;
}
