import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
} from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * Filtro global de excepciones HTTP.
 * Normaliza errores al formato { error: string, mensaje: string | string[] }.
 * 409 → transición de estado inválida desde el estado actual.
 * 422 → guarda de negocio fallida (checklist, revisión, conclusión).
 * 503 → proveedor de IA no disponible.
 */
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    let error = 'Error';
    let mensaje: string | string[] = exception.message;

    if (typeof exceptionResponse === 'string') {
      mensaje = exceptionResponse;
    } else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
      const res = exceptionResponse as {
        error?: string;
        message?: string | string[];
      };

      error = res.error ?? exception.name;
      mensaje = res.message ?? exception.message;
    }

    response.status(status).json({
      statusCode: status,
      error,
      mensaje,
      path: request.url,
      timestamp: new Date().toISOString(),
    });
  }
}