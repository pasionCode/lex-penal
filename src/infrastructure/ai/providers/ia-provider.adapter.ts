import { IAContexto, IARespuesta } from '../../../types/interfaces';

/**
 * Contrato común para adaptadores de proveedor de IA (ADR-004, R07).
 * Toda implementación debe respetar esta interfaz.
 * Añadir un proveedor = implementar esta interfaz, sin tocar IAService.
 */
export interface IAPayload {
  sistema: string;
  mensajes: { rol: 'usuario' | 'asistente'; contenido: string }[];
  modelo: string;
  max_tokens: number;
}

export abstract class IAProviderAdapter {
  abstract consultar(payload: IAPayload, contexto: IAContexto): Promise<IARespuesta>;
}
