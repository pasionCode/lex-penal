import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

/**
 * Guard de autenticación JWT.
 * Valida el token de sesión en cookie HttpOnly o header Authorization.
 * ADR-007: JWT simple, 8h, sin refresh token en MVP.
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  canActivate(_context: ExecutionContext): boolean {
    throw new Error('not implemented');
  }
}
