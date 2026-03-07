import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';

/**
 * Repositorio de evidence.
 * Único punto de acceso a la persistencia del módulo.
 * Depende de PrismaService (ADR-006).
 */
@Injectable()
export class EvidenceRepository {
  constructor(private readonly prisma: PrismaService) {}
}
