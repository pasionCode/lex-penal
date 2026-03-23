import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * Guard de autenticación JWT.
 * Protege rutas que requieren usuario autenticado.
 * 
 * Uso:
 * @UseGuards(JwtAuthGuard)
 * @Get('ruta-protegida')
 * handler() { ... }
 * 
 * Comportamiento:
 * - Token válido: permite acceso, req.user contiene el payload
 * - Token ausente/inválido/expirado: responde 401 Unauthorized
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}
