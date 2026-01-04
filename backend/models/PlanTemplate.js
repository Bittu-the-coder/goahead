import mongoose from 'mongoose';

const templateScheduleSchema = new mongoose.Schema({
  day: String,
  subjects: [{
    name: String,
    startTime: String,
    endTime: String,
    duration: Number,
    topics: [String],
    priority: String
  }],
  totalHours: Number,
  breakTime: Number
});

const planTemplateSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  type: {
    type: String,
    enum: ['CAT', 'GMAT', 'UPSC', 'JEE', 'NEET', 'SSC', 'DSA', 'General'],
    required: true
  },
  description: {
    type: String,
    required: true
  },
  duration: {
    weeks: { type: Number, required: true },
    months: { type: Number }
  },
  difficulty: {
    type: String,
    enum: ['beginner', 'intermediate', 'advanced'],
    default: 'intermediate'
  },
  weeklySchedule: [templateScheduleSchema],
  subjects: [{
    name: String,
    weeklyHours: Number,
    importance: String
  }],
  features: [String],
  tips: [String],
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

export default mongoose.model('PlanTemplate', planTemplateSchema);
