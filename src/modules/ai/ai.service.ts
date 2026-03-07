import { Injectable } from '@nestjs/common';
import { AnthropicAdapter } from '../../infrastructure/ai/providers/anthropic.adapter';
import { IAContextBuilder } from './context-builders/ai-context-builder';
import { AIRequestLogRepository } from './logging/ai-request-log.repository';

/**
 * Orquesta el flujo completo de una consulta (ARQUITECTURA_MODULO_IA_v3):
 * 1. IAContextBuilder.construir(caso_id, herramienta) → repositorios correctos
 * 2. PromptTemplateRepository.obtener(herramienta) → archivo .txt del repo
 * 3. Construir prompt completo
 * 4. IAOrchestrator.ejecutar(payload) → IAProviderAdapter → proveedor
 * 5. AIRequestLogRepository.insertar(log) ← SIEMPRE, incluso si falló
 * 6. Retornar { contenido, tokens_entrada, tokens_salida, modelo_usado }
 *
 * Si el log falla tras respuesta exitosa → 500, no 503 (RI-IA-02).
 */
@Injectable()
export class AIService {
  constructor(
    private readonly contextBuilder: IAContextBuilder,
    private readonly provider: AnthropicAdapter,
    private readonly logRepository: AIRequestLogRepository,
  ) {}

  consultar(
    _casoId: string,
    _herramienta: string,
    _consulta: string,
    _usuarioId: string,
  ): Promise<unknown> {
    throw new Error('not implemented');
  }
}
