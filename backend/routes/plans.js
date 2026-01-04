import express from 'express';
import {
    createPlan,
    deletePlan,
    getPlan,
    getPlans,
    getTemplate,
    getTemplates,
    toggleSubjectCompletion,
    updateDaySchedule,
    updatePlan,
    updateProgress
} from '../controllers/planController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.get('/templates', getTemplates);
router.get('/templates/:id', getTemplate);

// Protected routes
router.route('/')
  .get(protect, getPlans)
  .post(protect, createPlan);

router.route('/:id')
  .get(protect, getPlan)
  .put(protect, updatePlan)
  .delete(protect, deletePlan);

router.patch('/:id/progress', protect, updateProgress);
router.patch('/:id/subject/complete', protect, toggleSubjectCompletion);
router.patch('/:id/schedule/:day', protect, updateDaySchedule);

export default router;
