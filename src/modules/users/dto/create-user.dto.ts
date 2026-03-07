import { PerfilUsuario } from '../../../types/enums';

/** Campos requeridos para crear un usuario (MODELO_DATOS_v3 — tabla usuarios). */
export class CreateUserDto {
  nombre!: string;
  email!: string;
  password!: string;
  perfil!: PerfilUsuario;
}
