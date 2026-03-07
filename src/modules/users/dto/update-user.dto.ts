import { PerfilUsuario } from '../../../types/enums';

/** Campos actualizables de un usuario (perfil, activo). */
export class UpdateUserDto {
  nombre?: string;
  perfil?: PerfilUsuario;
  activo?: boolean;
}
