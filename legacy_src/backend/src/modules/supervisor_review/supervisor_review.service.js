export function buildSupervisorReview(caseRecord) {
  const riskLevel = caseRecord.risk_level || 'medium';
  const required = ['high', 'critical'].includes(riskLevel) || caseRecord.status === 'ready_for_review';
  return {
    required,
    approved: false,
    notes: required ? 'Pendiente revision de supervisor.' : 'No requerida por riesgo actual.'
  };
}
