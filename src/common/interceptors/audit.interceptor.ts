import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';

/**
 * Interceptor de auditoría transversal.
 * Registra eventos críticos en eventos_auditoria (R06).
 * Las operaciones críticas sin registro de auditoría deben fallar.
 */
@Injectable()
export class AuditInterceptor implements NestInterceptor {
  intercept(_context: ExecutionContext, next: CallHandler): Observable<unknown> {
    throw new Error('not implemented');
  }
}
