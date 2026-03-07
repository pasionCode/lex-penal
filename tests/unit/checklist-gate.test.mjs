import test from 'node:test';
import assert from 'node:assert/strict';
import { canAdvanceToClosure, getMissingRequiredChecklistBlocks } from '../../src/shared/rules/checklist-gate.js';

test('detecta bloques obligatorios pendientes', () => {
  const checklist = [
    { key: 'ficha', required: true, completed: true },
    { key: 'hechos', required: true, completed: false }
  ];
  const missing = getMissingRequiredChecklistBlocks(checklist);
  assert.equal(missing.length, 1);
  assert.equal(canAdvanceToClosure(checklist), false);
});

test('permite cierre cuando no faltan bloques requeridos', () => {
  const checklist = [
    { key: 'ficha', required: true, completed: true },
    { key: 'hechos', required: true, completed: true }
  ];
  assert.equal(canAdvanceToClosure(checklist), true);
});
