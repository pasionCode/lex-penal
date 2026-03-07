import { Module } from '@nestjs/common';
import { AnthropicAdapter } from '../../infrastructure/ai/providers/anthropic.adapter';
import { AIController } from './ai.controller';
import { AIService } from './ai.service';
import { AIContextBuilder } from './context-builders/ai-context-builder';
import { BasicInfoContextBuilder } from './context-builders/basic-info.context-builder';
import { FactsContextBuilder } from './context-builders/facts.context-builder';
import { EvidenceContextBuilder } from './context-builders/evidence.context-builder';
import { RisksContextBuilder } from './context-builders/risks.context-builder';
import { StrategyContextBuilder } from './context-builders/strategy.context-builder';
import { ClientBriefingContextBuilder } from './context-builders/client-briefing.context-builder';
import { ChecklistContextBuilder } from './context-builders/checklist.context-builder';
import { ConclusionContextBuilder } from './context-builders/conclusion.context-builder';
import { AIRequestLogRepository } from './logging/ai-request-log.repository';

/**
 * Módulo de IA (ADR-004, R05, R07).
 * IAProviderAdapter y AnthropicAdapter viven en src/infrastructure/ai/providers/.
 * Plantillas en src/modules/ai/prompt-templates/ (archivos .txt versionados).
 * IAContextBuilder resuelve qué repositorios consultar por herramienta.
 */
@Module({
  controllers: [AIController],
  providers: [
    AIService,
    AIRequestLogRepository,
    AIContextBuilder,
    BasicInfoContextBuilder,
    FactsContextBuilder,
    EvidenceContextBuilder,
    RisksContextBuilder,
    StrategyContextBuilder,
    ClientBriefingContextBuilder,
    ChecklistContextBuilder,
    ConclusionContextBuilder,
    AnthropicAdapter,
  ],
  exports: [AIService],
})
export class AIModule {}
