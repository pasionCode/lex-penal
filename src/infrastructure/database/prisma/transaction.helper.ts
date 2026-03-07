import { PrismaClient } from '@prisma/client';
import { PrismaService } from './prisma.service';

/**
 * Helper de transacciones Prisma.
 * Uso obligatorio en operaciones atómicas, por ejemplo:
 * - Transición de estado + creación de estructura base (R08)
 * - Registro de auditoría atómico con la operación crítica (R06)
 */
export async function withTransaction<T>(
  prisma: PrismaService,
  fn: (tx: PrismaClient) => Promise<T>,
): Promise<T> {
  return prisma.$transaction((tx) => fn(tx));
}
