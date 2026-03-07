import { Injectable } from '@nestjs/common';
import { IAContexto } from '../../../types/interfaces';

/**
 * Builder de contexto para herramienta: conclusion
 * Consulta los repositorios necesarios y retorna IAContexto tipado.
 * Ver tabla de repositorios en ai-context-builder.ts.
 */
@Injectable()
export class ConclusionContextBuilder {
  construir(_casoId: string): Promise<IAContexto> {
    throw new Error('not implemented');
  }
}
