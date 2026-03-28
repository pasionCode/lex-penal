import {
  IsString,
  IsEmail,
  IsEnum,
  IsBoolean,
  IsOptional,
  MinLength,
  MaxLength,
} from 'class-validator';
import { PerfilUsuario } from '../../../types/enums';

/**
 * DTO para actualización de usuario.
 * PUT /api/v1/users/:id
 *
 * Campos actualizables:
 * - nombre
 * - email (con validación de duplicado)
 * - perfil
 * - activo
 *
 * Fuera de alcance: password (requiere flujo separado)
 */
export class UpdateUserDto {
  @IsOptional()
  @IsString({ message: 'nombre debe ser texto' })
  @MinLength(2, { message: 'nombre debe tener al menos 2 caracteres' })
  @MaxLength(100, { message: 'nombre no puede exceder 100 caracteres' })
  nombre?: string;

  @IsOptional()
  @IsEmail({}, { message: 'email debe tener formato válido' })
  @MaxLength(255, { message: 'email no puede exceder 255 caracteres' })
  email?: string;

  @IsOptional()
  @IsEnum(PerfilUsuario, {
    message: 'perfil debe ser: estudiante, supervisor o administrador',
  })
  perfil?: PerfilUsuario;

  @IsOptional()
  @IsBoolean({ message: 'activo debe ser booleano' })
  activo?: boolean;
}
