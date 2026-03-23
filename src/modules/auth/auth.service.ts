import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { LoginResponseDto } from './dto/login-response.dto';

/**
 * Payload del JWT.
 * Solo contiene datos mínimos necesarios para identificar al usuario.
 * iat y exp son manejados automáticamente por JwtService.
 */
export interface JwtPayload {
  sub: string;
  email: string;
  perfil: string;
}

/**
 * Servicio de autenticación.
 * Valida credenciales, emite JWT, invalida sesión.
 */
@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Autentica un usuario y genera JWT.
   * US-01: Iniciar sesión.
   *
   * @param dto Credenciales de login
   * @returns Token de acceso y datos básicos del usuario
   * @throws UnauthorizedException si las credenciales son inválidas
   */
  async login(dto: LoginDto): Promise<LoginResponseDto> {
    // Buscar usuario por email (se normaliza internamente)
    const user = await this.usersService.findByEmail(dto.email);

    // Usuario no existe → error genérico
    if (!user) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Usuario inactivo → error genérico
    if (!user.activo) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Verificar contraseña
    const isPasswordValid = await this.usersService.verifyPassword(
      dto.password,
      user.password_hash,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Credenciales inválidas');
    }

    // Generar JWT
    const payload: JwtPayload = {
      sub: user.id,
      email: user.email,
      perfil: user.perfil,
    };

    const accessToken = this.jwtService.sign(payload);

    // Retornar respuesta sin datos sensibles
    return {
      access_token: accessToken,
      user: {
        id: user.id,
        nombre: user.nombre,
        email: user.email,
        perfil: user.perfil,
      },
    };
  }

  /**
   * Cierra la sesión del usuario.
   * US-03: Cerrar sesión.
   *
   * Nota: En JWT stateless, el logout es semántico.
   * El cliente debe eliminar el token de su almacenamiento.
   * Una implementación más robusta requeriría blacklist de tokens.
   */
  logout(): void {
    // JWT stateless: no hay estado de sesión que destruir en servidor.
    // Este método existe para completar el contrato de la API
    // y permitir al cliente un cierre semántico de sesión.
  }

  /**
   * Valida un token y retorna el payload.
   * Usado internamente por JwtStrategy.
   *
   * @param token JWT a validar
   * @returns Payload del token o null si inválido
   */
  validateToken(token: string): JwtPayload | null {
    try {
      return this.jwtService.verify<JwtPayload>(token);
    } catch {
      return null;
    }
  }
}
