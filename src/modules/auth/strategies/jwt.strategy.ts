import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

/**
 * Payload contenido en el JWT.
 * Coincide con lo firmado en AuthService.login()
 */
export interface JwtPayload {
  sub: string;
  email: string;
  perfil: string;
  iat?: number;
  exp?: number;
}

/**
 * Estrategia JWT para Passport.
 * Extrae el token del header Authorization: Bearer <token>
 * Valida la firma con JWT_SECRET.
 * Retorna el payload como req.user.
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    const secret = configService.get<string>('JWT_SECRET');
    
    if (!secret) {
      throw new Error('JWT_SECRET no está configurado');
    }

    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: secret,
    });
  }

  /**
   * Validación del payload.
   * Se ejecuta después de que Passport verifica la firma del token.
   * 
   * @param payload Contenido decodificado del JWT
   * @returns El payload que se asignará a req.user
   */
  validate(payload: JwtPayload): JwtPayload {
    if (!payload.sub || !payload.email || !payload.perfil) {
      throw new UnauthorizedException('Token inválido');
    }

    return {
      sub: payload.sub,
      email: payload.email,
      perfil: payload.perfil,
    };
  }
}
