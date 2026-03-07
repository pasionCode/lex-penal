import { Router } from 'express';
import { buildCaseReport } from '../modules/reports/reports.service.js';

const router = Router();

router.get('/:id', async (req, res, next) => {
  try { res.json({ ok: true, data: await buildCaseReport(req.params.id) }); } catch (error) { next(error); }
});

export default router;
