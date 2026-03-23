import { PerfilUsuario } from '@prisma/client';

/**
 * Datos del usuario retornados en la respuesta de login.
 * No incluye datos sensibles (password_hash, creado_por, etc.)
 */
export class LoginUserDto {
  id!: string;
  nombre!: string;
  email!: string;
  perfil!: PerfilUsuario;
}

/**
 * Respuesta exitosa del endpoint POST /api/v1/auth/login
 */
export class LoginResponseDto {
  access_token!: string;
  user!: LoginUserDto;
}
