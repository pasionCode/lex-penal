import dotenv from 'dotenv';
import { resolve } from 'node:path';

dotenv.config({ path: resolve(process.cwd(), '.env') });

function parseNumber(value, fallback) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

export const env = {
  appName: process.env.APP_NAME || 'LexPenal API',
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseNumber(process.env.PORT, 8080),
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseNumber(process.env.DB_PORT, 5432),
    database: process.env.DB_NAME || 'lexpenal',
    user: process.env.DB_USER || 'lexpenal',
    password: process.env.DB_PASSWORD || 'lexpenal'
  },
  demoAdmin: {
    email: process.env.DEMO_ADMIN_EMAIL || 'admin@lexpenal.local',
    password: process.env.DEMO_ADMIN_PASSWORD || 'ChangeMe123!',
    token: process.env.DEMO_ADMIN_TOKEN || 'demo-admin-token'
  },
  aiProvider: process.env.AI_PROVIDER || 'stub'
};
