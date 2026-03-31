import express from 'express';
import { googleSignIn } from '../controllers/authController';

const router = express.Router();

router.post('/google', googleSignIn);

export default router;
