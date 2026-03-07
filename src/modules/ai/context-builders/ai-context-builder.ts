import { Injectable } from '@nestjs/common';
import { HerramientaIA } from '../../../types/enums';
import { IAContexto } from '../../../types/interfaces';

/**
 * Orquestador de context builders.
 * Resuelve qué builder usar según el valor canónico de herramienta.
 * Cada builder sabe qué repositorios consultar para su herramienta.
 *
 * Mapa de repositorios por herramienta (ARQUITECTURA_MODULO_IA_v3):
 * basic-info     → casos
 * facts          → casos, hechos
 * evidence       → casos, pruebas
 * risks          → casos, riesgos
 * strategy       → casos, estrategia, actuaciones
 * client-briefing→ casos, clientes, explicacion_cliente
 * checklist      → casos, checklist_bloques, checklist_items
 * conclusion     → casos, conclusion_operativa
 */
@Injectable()
export class AIContextBuilder {
  construir(_casoId: string, _herramienta: HerramientaIA): Promise<IAContexto> {
    throw new Error('not implemented');
  }
}
