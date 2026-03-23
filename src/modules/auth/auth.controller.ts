import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { LoginResponseDto } from './dto/login-response.dto';

/**
 * Controller de autenticación.
 *
 * Endpoints:
 * POST /api/v1/auth/login   - Iniciar sesión (US-01)
 * POST /api/v1/auth/logout  - Cerrar sesión (US-03)
 *
 * Nota: GET /auth/session se agregará en US-02 con JwtAuthGuard.
 */
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /api/v1/auth/login
   * US-01: Iniciar sesión.
   *
   * Autentica usuario con email y password, retorna JWT.
   *
   * @param dto Credenciales de login
   * @returns Token de acceso y datos del usuario
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() dto: LoginDto): Promise<LoginResponseDto> {
    return this.authService.login(dto);
  }

  /**
   * POST /api/v1/auth/logout
   * US-03: Cerrar sesión.
   *
   * En JWT stateless, el logout es semántico.
   * El cliente debe eliminar el token de su almacenamiento.
   */
  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  logout(): void {
    return this.authService.logout();
  }
}
