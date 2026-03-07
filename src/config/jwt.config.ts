/**
 * Configuración JWT (ADR-007).
 * Token 8h. Cookie HttpOnly + Bearer. Sin refresh token en MVP.
 */
export const jwtConfig = () => ({
  secret: process.env.JWT_SECRET,
  expiresIn: process.env.JWT_EXPIRES_IN ?? '8h',
});
