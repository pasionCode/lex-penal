/** linea_principal obligatorio para transición a pendiente_revision (R02, CONTRATO_API_v4). */
export class UpdateStrategyDto {
  linea_principal?: string;
  fundamento_juridico?: string;
  fundamento_probatorio?: string;
  linea_subsidiaria?: string;
  posicion_allanamiento?: string;
  posicion_preacuerdo?: string;
  posicion_juicio?: string;
}

export class CreateProceedingDto {
  descripcion!: string;
  fecha?: string;
  responsable_id?: string;
  responsable_externo?: string;
  completada?: boolean;
}
