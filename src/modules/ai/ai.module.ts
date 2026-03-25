import { Module } from '@nestjs/common';
import { AIController } from './ai.controller';
import { AIService } from './ai.service';
import { AIRepository } from './ai.repository';
import { PrismaModule } from '../../infrastructure/database/prisma/prisma.module';

/**
 * Módulo de IA — MVP simplificado.
 * Usa placeholder en lugar de proveedor real.
 */
@Module({
  imports: [PrismaModule],
  controllers: [AIController],
  providers: [AIService, AIRepository],
  exports: [AIService],
})
export class AIModule {}