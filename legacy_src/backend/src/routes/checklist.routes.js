import { Router } from 'express';
import { getOneCase, updateChecklist } from '../modules/cases/cases.service.js';

const router = Router();

router.get('/:id', async (req, res, next) => {
  try {
    const caseRecord = await getOneCase(req.params.id);
    res.json({ ok: true, data: caseRecord.checklist });
  } catch (error) {
    next(error);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const updated = await updateChecklist(req.params.id, req.body, req.user?.email);
    res.json({ ok: true, data: updated.checklist });
  } catch (error) {
    next(error);
  }
});

export default router;
