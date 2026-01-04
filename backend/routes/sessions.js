import express from 'express';
import {
    createSession,
    deleteSession,
    getSession,
    getSessions,
    getStats,
    updateSession
} from '../controllers/sessionController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.use(protect);

router.get('/stats', getStats);

router.route('/')
  .get(getSessions)
  .post(createSession);

router.route('/:id')
  .get(getSession)
  .put(updateSession)
  .delete(deleteSession);

export default router;
