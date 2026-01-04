import mongoose from 'mongoose';

const dayScheduleSchema = new mongoose.Schema({
  day: {
    type: String,
    enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    required: true
  },
  subjects: [{
    name: { type: String, required: true },
    startTime: { type: String, required: true }, // Format: "09:00"
    endTime: { type: String, required: true },
    duration: { type: Number, required: true }, // in minutes
    topics: [String],
    priority: {
      type: String,
      enum: ['high', 'medium', 'low'],
      default: 'medium'
    },
    completed: { type: Boolean, default: false },
    completedDate: { type: Date }
  }],
  totalHours: { type: Number, default: 0 },
  breakTime: { type: Number, default: 0 } // in minutes
});

const studyPlanSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: true,
    trim: true
  },
  templateType: {
    type: String,
    enum: ['CAT', 'GMAT', 'UPSC', 'JEE', 'NEET', 'SSC', 'DSA', 'General', 'Custom'],
    required: true
  },
  description: String,
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  },
  weeklySchedule: [dayScheduleSchema],
  totalWeeks: Number,
  isActive: {
    type: Boolean,
    default: true
  },
  progress: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  customizations: {
    type: Map,
    of: mongoose.Schema.Types.Mixed
  }
}, {
  timestamps: true
});

// Calculate total hours and auto-progress before saving
studyPlanSchema.pre('save', function(next) {
  // Calculate total hours per day
  this.weeklySchedule.forEach(day => {
    day.totalHours = day.subjects.reduce((total, subject) => {
      return total + (subject.duration / 60);
    }, 0);
  });

  // Auto-calculate progress based on completed subjects
  let totalSubjects = 0;
  let completedSubjects = 0;

  this.weeklySchedule.forEach(day => {
    day.subjects.forEach(subject => {
      totalSubjects++;
      if (subject.completed) {
        completedSubjects++;
      }
    });
  });

  if (totalSubjects > 0) {
    this.progress = Math.round((completedSubjects / totalSubjects) * 100);
  }

  next();
});

export default mongoose.model('StudyPlan', studyPlanSchema);
