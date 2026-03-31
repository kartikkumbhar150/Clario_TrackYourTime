import express from 'express';
import { createTimeSlot, getTimeSlots } from '../controllers/slotController';
import { protect } from '../middleware/authMiddleware';

const router = express.Router();

router.route('/')
  .post(protect, createTimeSlot)
  .get(protect, getTimeSlots);

export default router;
