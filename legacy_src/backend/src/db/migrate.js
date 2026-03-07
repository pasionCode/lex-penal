import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pool } from './pool.js';
import { logger } from '../config/logger.js';

const schemaPath = resolve(process.cwd(), '../../infra/postgres/init/001_schema.sql');

try {
  const sql = await readFile(schemaPath, 'utf8');
  await pool.query(sql);
  logger.info('Migracion ejecutada', { schemaPath });
  process.exit(0);
} catch (error) {
  logger.error('Error ejecutando migracion', { message: error.message });
  process.exit(1);
} finally {
  await pool.end();
}
