import { pool } from '../../db/pool.js';

export async function writeAuditLog({ action, entityType, entityId, payload = {}, actor = 'system' }) {
  await pool.query(
    `insert into audit_logs (action, entity_type, entity_id, actor, payload)
     values ($1, $2, $3, $4, $5::jsonb)`,
    [action, entityType, entityId, actor, JSON.stringify(payload)]
  );
}
