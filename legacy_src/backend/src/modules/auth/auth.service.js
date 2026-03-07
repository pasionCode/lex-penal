import { z } from 'zod';
import { env } from '../../config/env.js';

const loginSchema = z.object({ email: z.string().email(), password: z.string().min(8) });

export function login(payload) {
  const data = loginSchema.parse(payload);
  if (data.email !== env.demoAdmin.email || data.password !== env.demoAdmin.password) {
    const error = new Error('Credenciales invalidas');
    error.statusCode = 401;
    throw error;
  }
  return { token: env.demoAdmin.token, user: { email: env.demoAdmin.email, role: 'admin' } };
}
