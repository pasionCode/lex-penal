/**
 * Configuración general de la aplicación.
 * Todas las variables de entorno se leen aquí, nunca en servicios.
 */
export const appConfig = () => ({
  port: parseInt(process.env.PORT ?? '3001', 10),
  nodeEnv: process.env.NODE_ENV ?? 'development',
});
