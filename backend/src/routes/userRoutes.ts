import express from 'express';
import { getUserCategories, updateUserCategories } from '../controllers/userController';
import { protect } from '../middleware/authMiddleware';

const router = express.Router();

router.route('/categories')
  .get(protect, getUserCategories)
  .put(protect, updateUserCategories);

export default router;
