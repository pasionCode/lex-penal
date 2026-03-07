import { Router } from 'express';
import { createNewCase, getOneCase, listAllCases, changeCaseStatus } from '../modules/cases/cases.service.js';

const router = Router();

router.get('/', async (req, res, next) => {
  try { res.json({ ok: true, data: await listAllCases() }); } catch (error) { next(error); }
});

router.post('/', async (req, res, next) => {
  try { res.status(201).json({ ok: true, data: await createNewCase(req.body, req.user?.email) }); } catch (error) { next(error); }
});

router.get('/:id', async (req, res, next) => {
  try { res.json({ ok: true, data: await getOneCase(req.params.id) }); } catch (error) { next(error); }
});

router.patch('/:id/status', async (req, res, next) => {
  try { res.json({ ok: true, data: await changeCaseStatus(req.params.id, req.body, req.user?.email) }); } catch (error) { next(error); }
});

export default router;
