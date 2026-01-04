import express from 'express';
import {
    createTask,
    deleteTask,
    getTask,
    getTasks,
    toggleTaskComplete,
    updateTask
} from '../controllers/taskController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.use(protect);

router.route('/')
  .get(getTasks)
  .post(createTask);

router.route('/:id')
  .get(getTask)
  .put(updateTask)
  .delete(deleteTask);

router.patch('/:id/complete', toggleTaskComplete);

export default router;
