import { Module } from '@nestjs/common';
import { CasesController } from './cases.controller';
import { CasesService } from './cases.service';
import { CasesRepository } from './cases.repository';
import { CasoEstadoService } from './services/caso-estado.service';

/**
 * Módulo de casos.
 * Incluye CasoEstadoService que debe ser usado por otros módulos
 * para verificar permisos de escritura (R08, R09).
 */
@Module({
  controllers: [CasesController],
  providers: [
    CasesService,
    CasesRepository,
    CasoEstadoService,
  ],
  exports: [CasesService, CasoEstadoService],
})
export class CasesModule {}
