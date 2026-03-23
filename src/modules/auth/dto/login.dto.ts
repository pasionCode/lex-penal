import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

/**
 * Credenciales de acceso al sistema.
 * POST /api/v1/auth/login
 */
export class LoginDto {
  @IsEmail({}, { message: 'Formato de email inválido' })
  @IsNotEmpty({ message: 'Email es obligatorio' })
  email!: string;

  @IsString({ message: 'Password debe ser texto' })
  @IsNotEmpty({ message: 'Password es obligatorio' })
  password!: string;
}
