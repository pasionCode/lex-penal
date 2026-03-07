import { env } from '../config/env.js';

export function authMiddleware(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.replace('Bearer ', '').trim();

  if (!token || token !== env.demoAdmin.token) {
    return res.status(401).json({ ok: false, message: 'No autorizado' });
  }

  req.user = { email: env.demoAdmin.email, role: 'admin' };
  next();
}
