import express from 'express';
import {
    getBadges,
    getStatsSummary,
    getStreakCalendar,
    updateStats
} from '../controllers/statsController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// All routes are protected
router.use(protect);

router.get('/summary', getStatsSummary);
router.get('/badges', getBadges);
router.get('/calendar', getStreakCalendar);
router.post('/update', updateStats);

export default router;
