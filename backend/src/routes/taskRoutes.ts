import express from 'express';
import { createTask, getTasks, markTaskCompleted } from '../controllers/taskController';
import { protect } from '../middleware/authMiddleware';

const router = express.Router();

router.route('/')
  .post(protect, createTask)
  .get(protect, getTasks);

// PUT is allowed only for completion, not for renaming or deletion. Immutable rule.
router.put('/:id/complete', protect, markTaskCompleted);

export default router;
