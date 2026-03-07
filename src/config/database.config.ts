/** Configuración de conexión a PostgreSQL vía Prisma (ADR-002, ADR-006). */
export const databaseConfig = () => ({
  databaseUrl: process.env.DATABASE_URL,
});
