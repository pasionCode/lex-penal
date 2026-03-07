import { Router } from 'express';
import { env } from '../config/env.js';
import { healthcheckDb } from '../db/pool.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try {
    const dbOk = await healthcheckDb();
    res.json({ ok: true, app: env.appName, environment: env.nodeEnv, database: dbOk ? 'up' : 'down' });
  } catch (error) {
    next(error);
  }
});

export default router;
