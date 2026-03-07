import { Router } from 'express';
import { API_PREFIX } from '../../../shared/constants/app.constants.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';
import healthRoutes from './health.routes.js';
import authRoutes from './auth.routes.js';
import casesRoutes from './cases.routes.js';
import checklistRoutes from './checklist.routes.js';
import reportsRoutes from './reports.routes.js';

const router = Router();

router.use(`${API_PREFIX}/health`, healthRoutes);
router.use(`${API_PREFIX}/auth`, authRoutes);
router.use(`${API_PREFIX}/cases`, authMiddleware, casesRoutes);
router.use(`${API_PREFIX}/checklist`, authMiddleware, checklistRoutes);
router.use(`${API_PREFIX}/reports`, authMiddleware, reportsRoutes);

export default router;
