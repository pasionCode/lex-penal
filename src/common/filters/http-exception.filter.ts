import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
} from '@nestjs/common';
import { Response } from 'express';

/**
 * Filtro global de excepciones HTTP.
 * Normaliza errores al formato { error: string, mensaje: string }.
 * 409 → transición de estado inválida desde el estado actual.
 * 422 → guarda de negocio fallida (checklist, revisión, conclusión).
 * 503 → proveedor de IA no disponible.
 */
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(_exception: HttpException, _host: ArgumentsHost): void {
    throw new Error('not implemented');
  }
}
