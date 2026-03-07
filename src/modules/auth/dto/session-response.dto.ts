/** Datos del usuario autenticado retornados por GET /auth/session. */
export class SessionResponseDto {
  id!: string;
  nombre!: string;
  email!: string;
  perfil!: string;
}
