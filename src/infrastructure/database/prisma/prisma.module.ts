import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

/**
 * Módulo global de Prisma.
 * @Global permite que PrismaService esté disponible en todos los módulos
 * sin importación explícita. (ADR-006)
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
