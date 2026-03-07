import { pool } from './pool.js';
import { cloneDefaultChecklist } from '../../../shared/catalogs/checklist-blocks.js';
import { logger } from '../config/logger.js';

const sampleCase = {
  code: 'LP-DEMO-001',
  title: 'Caso demostracion de defensa penal',
  client_name: 'Cliente Demo',
  status: 'draft',
  risk_level: 'medium',
  facts: { summary: 'Caso semilla para validar flujo tecnico inicial.' },
  checklist: cloneDefaultChecklist(),
  supervisor_review: { required: true, approved: false, notes: 'Pendiente revision.' }
};

try {
  const existing = await pool.query('select id from cases where code = $1', [sampleCase.code]);
  if (existing.rowCount === 0) {
    await pool.query(
      `insert into cases (code, title, client_name, status, risk_level, facts, checklist, supervisor_review)
       values ($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,$8::jsonb)`,
      [
        sampleCase.code,
        sampleCase.title,
        sampleCase.client_name,
        sampleCase.status,
        sampleCase.risk_level,
        JSON.stringify(sampleCase.facts),
        JSON.stringify(sampleCase.checklist),
        JSON.stringify(sampleCase.supervisor_review)
      ]
    );
  }

  logger.info('Seed aplicada');
  process.exit(0);
} catch (error) {
  logger.error('Error aplicando seed', { message: error.message });
  process.exit(1);
} finally {
  await pool.end();
}
