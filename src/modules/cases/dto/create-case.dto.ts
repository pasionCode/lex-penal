/** Campos mínimos para crear un caso (MODELO_DATOS_v3 — tabla casos). */
export class CreateCaseDto {
  cliente_id!: string;
  radicado!: string;
  delito_imputado!: string;
  regimen_procesal!: string;
  etapa_procesal!: string;
  despacho?: string;
  fecha_apertura?: string;
  agravantes?: string;
  observaciones?: string;
}
