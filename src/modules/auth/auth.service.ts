import { Injectable } from '@nestjs/common';

/**
 * Servicio de autenticación.
 * Valida credenciales, emite JWT, invalida sesión.
 * Un usuario desactivado no puede iniciar sesión (MODELO_DATOS_v3 — usuarios.activo).
 */
@Injectable()
export class AuthService {
  login(_email: string, _password: string): Promise<unknown> {
    throw new Error('not implemented');
  }

  logout(_token: string): Promise<void> {
    throw new Error('not implemented');
  }

  validateToken(_token: string): Promise<unknown> {
    throw new Error('not implemented');
  }
}
