import { randomUUID } from 'node:crypto';
import { z } from 'zod';
import { CASE_STATUS, CASE_STATUS_VALUES } from '../../../../shared/enums/case-status.js';
import { buildDefaultChecklist, normalizeChecklist, validateChecklistForClosure } from '../checklist/checklist.service.js';
import { buildSupervisorReview } from '../supervisor_review/supervisor_review.service.js';
import { analyzeCase } from '../ai_adapter/ai.provider.js';
import { writeAuditLog } from '../audit/audit.service.js';
import * as repository from './cases.repository.js';

const createCaseSchema = z.object({
  title: z.string().min(5),
  client_name: z.string().min(3),
  risk_level: z.enum(['low', 'medium', 'high', 'critical']).default('medium'),
  facts: z.record(z.any()).optional()
});

const updateStatusSchema = z.object({ status: z.enum(CASE_STATUS_VALUES) });

const checklistSchema = z.array(
  z.object({
    key: z.string(),
    label: z.string(),
    required: z.boolean(),
    completed: z.boolean(),
    notes: z.string().optional().default('')
  })
);

function buildCaseCode() {
  const stamp = new Date().toISOString().replace(/[-:TZ.]/g, '').slice(0, 14);
  return `LP-${stamp}-${randomUUID().slice(0, 8).toUpperCase()}`;
}

export async function listAllCases() { return repository.listCases(); }

export async function getOneCase(id) {
  const found = await repository.getCaseById(id);
  if (!found) {
    const error = new Error('Caso no encontrado');
    error.statusCode = 404;
    throw error;
  }
  return found;
}

export async function createNewCase(payload, actor = 'admin@lexpenal.local') {
  const data = createCaseSchema.parse(payload);
  const checklist = buildDefaultChecklist();
  const draftCase = {
    code: buildCaseCode(),
    title: data.title,
    client_name: data.client_name,
    status: CASE_STATUS.DRAFT,
    risk_level: data.risk_level,
    facts: data.facts || {},
    checklist,
    supervisor_review: buildSupervisorReview({ risk_level: data.risk_level, status: CASE_STATUS.DRAFT })
  };

  const analysis = await analyzeCase(draftCase);
  draftCase.facts = { ...draftCase.facts, ai_bootstrap_summary: analysis.summary };

  const created = await repository.createCase(draftCase);
  await writeAuditLog({ action: 'case.created', entityType: 'case', entityId: created.id, actor, payload: { code: created.code } });
  return created;
}

export async function changeCaseStatus(id, payload, actor = 'admin@lexpenal.local') {
  const data = updateStatusSchema.parse(payload);
  const current = await getOneCase(id);

  if ([CASE_STATUS.APPROVED, CASE_STATUS.CLOSED].includes(data.status)) {
    const gate = validateChecklistForClosure(current.checklist);
    if (!gate.allowed) {
      const error = new Error(`No es posible cerrar o aprobar el caso. Faltan bloques: ${gate.missing.map((x) => x.label).join(', ')}`);
      error.statusCode = 400;
      throw error;
    }
  }

  const updated = await repository.updateCaseStatus(id, data.status);
  await writeAuditLog({ action: 'case.status.changed', entityType: 'case', entityId: id, actor, payload: { status: data.status } });
  return updated;
}

export async function updateChecklist(id, payload, actor = 'admin@lexpenal.local') {
  const current = await getOneCase(id);
  const data = checklistSchema.parse(payload);
  const normalizedChecklist = normalizeChecklist(data);
  const updated = await repository.updateCaseChecklist(current.id, normalizedChecklist);

  await writeAuditLog({
    action: 'case.checklist.updated',
    entityType: 'case',
    entityId: id,
    actor,
    payload: { completedBlocks: normalizedChecklist.filter((item) => item.completed).length }
  });

  return updated;
}
