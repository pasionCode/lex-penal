import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

/**
 * Guard de autorización por perfil.
 * Perfiles: estudiante | supervisor | administrador
 * Requiere JwtAuthGuard aplicado previamente.
 */
@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(_context: ExecutionContext): boolean {
    throw new Error('not implemented');
  }
}
