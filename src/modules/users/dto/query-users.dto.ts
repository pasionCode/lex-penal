import { PerfilUsuario } from '../../../types/enums';

/** Filtros de listado de usuarios. */
export class QueryUsersDto {
  perfil?: PerfilUsuario;
  activo?: boolean;
  page?: number;
  per_page?: number;
}
