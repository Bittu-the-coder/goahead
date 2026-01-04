import mongoose from 'mongoose';

const taskSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: [true, 'Please provide a task title'],
    trim: true,
    maxlength: [100, 'Title cannot be more than 100 characters']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Description cannot be more than 500 characters']
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium'
  },
  status: {
    type: String,
    enum: ['todo', 'in-progress', 'completed'],
    default: 'todo'
  },
  category: {
    type: String,
    trim: true,
    default: 'general'
  },
  dueDate: {
    type: Date
  },
  completed: {
    type: Boolean,
    default: false
  },
  completedAt: {
    type: Date
  },
  tags: [{
    type: String,
    trim: true
  }]
}, {
  timestamps: true
});

// Update completedAt when task is marked as completed
taskSchema.pre('save', function(next) {
  if (this.isModified('completed') && this.completed) {
    this.completedAt = new Date();
    this.status = 'completed';
  } else if (this.isModified('completed') && !this.completed) {
    this.completedAt = null;
  }
  next();
});

const Task = mongoose.model('Task', taskSchema);

export default Task;
