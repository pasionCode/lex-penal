import { getOneCase } from '../cases/cases.service.js';
import { getMissingRequiredChecklistBlocks } from '../../../../shared/rules/checklist-gate.js';

export async function buildCaseReport(id) {
  const caseRecord = await getOneCase(id);
  const missing = getMissingRequiredChecklistBlocks(caseRecord.checklist);

  const body = [
    `# Informe operativo del caso ${caseRecord.code}`,
    '',
    `## Identificacion`,
    `- Titulo: ${caseRecord.title}`,
    `- Cliente: ${caseRecord.client_name}`,
    `- Estado: ${caseRecord.status}`,
    `- Riesgo: ${caseRecord.risk_level}`,
    '',
    '## Resumen de hechos',
    `${caseRecord.facts?.summary || 'Sin resumen registrado.'}`,
    '',
    '## Checklist vinculante',
    ...caseRecord.checklist.map((block) => `- [${block.completed ? 'x' : ' '}] ${block.label}`),
    '',
    '## Control de calidad',
    missing.length === 0 ? '- Todos los bloques obligatorios aparecen completados.' : `- Pendientes: ${missing.map((block) => block.label).join(', ')}`,
    '',
    '## Revision de supervisor',
    `- Requerida: ${caseRecord.supervisor_review?.required ? 'Si' : 'No'}`,
    `- Aprobada: ${caseRecord.supervisor_review?.approved ? 'Si' : 'No'}`,
    `- Notas: ${caseRecord.supervisor_review?.notes || 'Sin notas.'}`
  ].join('\n');

  return { caseId: caseRecord.id, code: caseRecord.code, format: 'markdown', content: body };
}
