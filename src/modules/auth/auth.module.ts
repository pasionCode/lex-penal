import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

/**
 * Módulo de autenticación y sesión (ADR-007).
 * JWT 8h · Cookie HttpOnly + Bearer · Sin refresh token en MVP.
 * Endpoints: POST /auth/login · POST /auth/logout · GET /auth/session
 */
@Module({
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}
