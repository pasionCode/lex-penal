import {
  IsBoolean,
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PerfilUsuario } from '../../../types/enums';

export class CreateUserDto {
  @IsString({ message: 'nombre debe ser texto' })
  @IsNotEmpty({ message: 'nombre es obligatorio' })
  @MaxLength(120, { message: 'nombre no puede exceder 120 caracteres' })
  nombre!: string;

  @IsEmail({}, { message: 'email debe tener formato válido' })
  @IsNotEmpty({ message: 'email es obligatorio' })
  email!: string;

  @IsString({ message: 'password debe ser texto' })
  @IsNotEmpty({ message: 'password es obligatorio' })
  @MinLength(8, { message: 'password debe tener al menos 8 caracteres' })
  password!: string;

  @IsEnum(PerfilUsuario, {
    message: `perfil debe ser uno de: ${Object.values(PerfilUsuario).join(', ')}`,
  })
  perfil!: PerfilUsuario;

  @IsOptional()
  @IsBoolean({ message: 'activo debe ser booleano' })
  activo?: boolean;
}
