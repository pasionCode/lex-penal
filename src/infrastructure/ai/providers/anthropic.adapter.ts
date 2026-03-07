import { Injectable } from '@nestjs/common';
import { IAContexto, IARespuesta } from '../../../types/interfaces';
import { IAPayload, IAProviderAdapter } from './ia-provider.adapter';

/**
 * Adaptador Anthropic — proveedor por defecto del MVP (ADR-004).
 * El modelo se lee siempre desde ia.config, nunca del código fuente (RI-IA-06).
 * Los parámetros operativos (timeout, reintentos) los hereda de la política central.
 */
@Injectable()
export class AnthropicAdapter extends IAProviderAdapter {
  async consultar(_payload: IAPayload, _contexto: IAContexto): Promise<IARespuesta> {
    throw new Error('not implemented');
  }
}
