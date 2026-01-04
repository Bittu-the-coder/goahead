import express from 'express';
import {
    createGoal,
    deleteGoal,
    getGoal,
    getGoals,
    toggleMilestone,
    updateGoal,
    updateProgress
} from '../controllers/goalController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.use(protect);

router.route('/')
  .get(getGoals)
  .post(createGoal);

router.route('/:id')
  .get(getGoal)
  .put(updateGoal)
  .delete(deleteGoal);

router.patch('/:id/progress', updateProgress);
router.patch('/:id/milestones/:milestoneId', toggleMilestone);

export default router;
