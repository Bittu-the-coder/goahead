import mongoose from 'mongoose';

const milestoneSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  completed: {
    type: Boolean,
    default: false
  },
  completedAt: {
    type: Date
  }
}, { _id: true });

const goalSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: [true, 'Please provide a goal title'],
    trim: true,
    maxlength: [100, 'Title cannot be more than 100 characters']
  },
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Description cannot be more than 500 characters']
  },
  category: {
    type: String,
    enum: ['daily', 'weekly', 'monthly', 'exam', 'custom'],
    default: 'custom'
  },
  targetDate: {
    type: Date,
    required: [true, 'Please provide a target date']
  },
  progress: {
    type: Number,
    min: 0,
    max: 100,
    default: 0
  },
  milestones: [milestoneSchema],
  completed: {
    type: Boolean,
    default: false
  },
  completedAt: {
    type: Date
  }
}, {
  timestamps: true
});

// Auto-complete goal when progress reaches 100%
goalSchema.pre('save', function(next) {
  if (this.isModified('progress') && this.progress >= 100 && !this.completed) {
    this.completed = true;
    this.completedAt = new Date();
  }
  next();
});

const Goal = mongoose.model('Goal', goalSchema);

export default Goal;
