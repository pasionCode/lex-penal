import pg from 'pg';
import { env } from '../config/env.js';

const { Pool } = pg;

export const pool = new Pool({
  host: env.db.host,
  port: env.db.port,
  database: env.db.database,
  user: env.db.user,
  password: env.db.password
});

export async function healthcheckDb() {
  const result = await pool.query('select 1 as ok');
  return result.rows[0]?.ok === 1;
}
