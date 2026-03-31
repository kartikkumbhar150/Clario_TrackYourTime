import express from 'express';
import { getAnalytics } from '../controllers/analyticsController';
import { protect } from '../middleware/authMiddleware';

const router = express.Router();

router.get('/:period', protect, getAnalytics);

export default router;
