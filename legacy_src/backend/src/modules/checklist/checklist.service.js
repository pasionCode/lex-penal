import { cloneDefaultChecklist } from '../../../../shared/catalogs/checklist-blocks.js';
import { canAdvanceToClosure, getMissingRequiredChecklistBlocks } from '../../../../shared/rules/checklist-gate.js';

export function buildDefaultChecklist() { return cloneDefaultChecklist(); }

export function normalizeChecklist(checklist = []) {
  const defaults = cloneDefaultChecklist();
  const incomingMap = new Map((checklist || []).map((item) => [item.key, item]));
  return defaults.map((block) => ({ ...block, ...(incomingMap.get(block.key) || {}) }));
}

export function validateChecklistForClosure(checklist = []) {
  const normalized = normalizeChecklist(checklist);
  const missing = getMissingRequiredChecklistBlocks(normalized);
  return { allowed: canAdvanceToClosure(normalized), missing };
}
