import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { UsersModule } from '../users/users.module';

/**
 * Módulo de autenticación y sesión.
 *
 * Configuración JWT:
 * - Secret: JWT_SECRET (variable de entorno)
 * - Expiración: JWT_EXPIRES_IN (variable de entorno, default 24h)
 *
 * Dependencias:
 * - UsersModule: para validar credenciales
 * - PassportModule: framework de autenticación
 * - JwtModule: para firmar y verificar tokens
 *
 * Exports:
 * - AuthService: para uso en otros módulos si es necesario
 * - JwtModule: para firmar tokens desde otros módulos
 * - JwtStrategy: para reutilizar en guards personalizados
 *
 * Endpoints:
 * - POST /auth/login   (US-01)
 * - POST /auth/logout  (US-03)
 */
@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('JWT_EXPIRES_IN', '24h'),
        },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService, JwtModule],
})
export class AuthModule {}
