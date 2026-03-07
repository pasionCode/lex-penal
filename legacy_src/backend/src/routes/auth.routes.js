import { Router } from 'express';
import { login } from '../modules/auth/auth.service.js';

const router = Router();

router.post('/login', (req, res, next) => {
  try {
    const session = login(req.body);
    res.json({ ok: true, data: session });
  } catch (error) {
    next(error);
  }
});

export default router;
