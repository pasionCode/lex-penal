import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma/prisma.service';

/**
 * Repositorio de review.
 * Único punto de acceso a la persistencia del módulo.
 * Depende de PrismaService (ADR-006).
 */
@Injectable()
export class ReviewRepository {
  constructor(private readonly prisma: PrismaService) {}
}
