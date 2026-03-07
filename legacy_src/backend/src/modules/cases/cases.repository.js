import { pool } from '../../db/pool.js';

export async function listCases() {
  const result = await pool.query(
    `select id, code, title, client_name, status, risk_level, checklist, supervisor_review, created_at, updated_at
     from cases
     order by created_at desc`
  );
  return result.rows;
}

export async function getCaseById(id) {
  const result = await pool.query(
    `select id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at
     from cases
     where id = $1`,
    [id]
  );
  return result.rows[0] || null;
}

export async function createCase(caseRecord) {
  const result = await pool.query(
    `insert into cases
     (code, title, client_name, status, risk_level, facts, checklist, supervisor_review)
     values ($1,$2,$3,$4,$5,$6::jsonb,$7::jsonb,$8::jsonb)
     returning id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at`,
    [
      caseRecord.code,
      caseRecord.title,
      caseRecord.client_name,
      caseRecord.status,
      caseRecord.risk_level,
      JSON.stringify(caseRecord.facts || {}),
      JSON.stringify(caseRecord.checklist || []),
      JSON.stringify(caseRecord.supervisor_review || {})
    ]
  );
  return result.rows[0];
}

export async function updateCaseStatus(id, status) {
  const result = await pool.query(
    `update cases
     set status = $2, updated_at = now()
     where id = $1
     returning id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at`,
    [id, status]
  );
  return result.rows[0] || null;
}

export async function updateCaseChecklist(id, checklist) {
  const result = await pool.query(
    `update cases
     set checklist = $2::jsonb, updated_at = now()
     where id = $1
     returning id, code, title, client_name, status, risk_level, facts, checklist, supervisor_review, created_at, updated_at`,
    [id, JSON.stringify(checklist)]
  );
  return result.rows[0] || null;
}
