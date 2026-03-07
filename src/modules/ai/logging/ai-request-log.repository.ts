import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma/prisma.service';

/**
 * Repositorio de log de IA — solo INSERT, nunca UPDATE ni DELETE (R05, RI-IA-02).
 * Registra toda llamada al módulo de IA, exitosa o fallida.
 * Si insertar falla después de respuesta exitosa → la operación retorna 500.
 * No puede haber llamadas no registradas.
 *
 * Campos: caso_id, usuario_id, herramienta, proveedor, modelo,
 *         prompt_enviado, respuesta_recibida, tokens_entrada, tokens_salida,
 *         duracion_ms, estado_llamada, error_mensaje.
 *
 * El endpoint GET /audit NO expone prompt_enviado ni respuesta_recibida.
 */
@Injectable()
export class AIRequestLogRepository {
  constructor(private readonly prisma: PrismaService) {}

  insertar(_log: Record<string, unknown>): Promise<void> {
    throw new Error('not implemented');
  }
}
