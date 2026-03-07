/**
 * Configuración del módulo de IA (ADR-004).
 * El proveedor, modelo y credenciales se leen siempre desde variables de entorno.
 * El nombre del modelo nunca aparece en código fuente (RI-IA-06).
 */
export const aiConfig = () => ({
  provider: process.env.IA_PROVIDER ?? 'anthropic',
  model: process.env.IA_MODEL,
  apiKey: process.env.IA_API_KEY,
  maxTokens: parseInt(process.env.IA_MAX_TOKENS ?? '1000', 10),
  timeoutMs: parseInt(process.env.IA_TIMEOUT_MS ?? '30000', 10),
});
