import { env } from '../../config/env.js';

export async function analyzeCase(caseRecord) {
  if (env.aiProvider === 'stub') {
    return {
      provider: 'stub',
      summary: 'Analisis IA no operativo. Proveedor stub activo.',
      recommendations: [
        'Completar checklist vinculante.',
        'Validar riesgos procesales.',
        'Revisar hipotesis de defensa.'
      ]
    };
  }

  return {
    provider: env.aiProvider,
    summary: 'Proveedor configurado pero no implementado en este bootstrap.',
    recommendations: []
  };
}
