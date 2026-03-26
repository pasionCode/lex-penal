import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { appConfig } from './config/app.config';
import { databaseConfig } from './config/database.config';
import { jwtConfig } from './config/jwt.config';
import { aiConfig } from './config/ai.config';

import { PrismaModule } from './infrastructure/database/prisma/prisma.module';

// Módulos de plataforma
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';

// Módulo agregado raíz
import { CasesModule } from './modules/cases/cases.module';

// Módulo de clientes
import { ClientsModule } from './modules/clients/clients.module';

// Herramientas operativas del caso
import { FactsModule } from './modules/facts/facts.module';
import { EvidenceModule } from './modules/evidence/evidence.module';
import { RisksModule } from './modules/risks/risks.module';
import { StrategyModule } from './modules/strategy/strategy.module';
import { TimelineModule } from './modules/timeline/timeline.module';
import { ClientBriefingModule } from './modules/client-briefing/client-briefing.module';
import { ChecklistModule } from './modules/checklist/checklist.module';
import { ConclusionModule } from './modules/conclusion/conclusion.module';

// Flujos formales
import { ReviewModule } from './modules/review/review.module';
import { ProceedingsModule } from './modules/proceedings/proceedings.module';
import { DocumentsModule } from './modules/documents/documents.module';
import { ReportsModule } from './modules/reports/reports.module';

// Transversales
import { AIModule } from './modules/ai/ai.module';
import { AuditModule } from './modules/audit/audit.module';

/**
 * Módulo raíz de LexPenal backend.
 * 15 módulos registrados según canon src/ (CONTRATO_API_v4, MODELO_DATOS_v3).
 * Stack: NestJS + TypeScript + Prisma + PostgreSQL (ADR-001, ADR-002, ADR-006).
 */
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, databaseConfig, jwtConfig, aiConfig],
    }),
    PrismaModule,
    // Plataforma
    AuthModule,
    UsersModule,
    // Dominio
    CasesModule,
    ClientsModule,
    // Herramientas
    FactsModule,
    EvidenceModule,
    RisksModule,
    StrategyModule,
    TimelineModule,
    ClientBriefingModule,
    ChecklistModule,
    ConclusionModule,
    // Flujos formales
    ReviewModule,
    ProceedingsModule,
    DocumentsModule,
    ReportsModule,
    // Transversales
    AIModule,
    AuditModule,
  ],
})
export class AppModule {}
