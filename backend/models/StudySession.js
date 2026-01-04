import mongoose from 'mongoose';

const studySessionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  subject: {
    type: String,
    required: [true, 'Please provide a subject'],
    trim: true
  },
  topic: {
    type: String,
    trim: true
  },
  startTime: {
    type: Date,
    required: true
  },
  endTime: {
    type: Date
  },
  duration: {
    type: Number, // in minutes
    default: 0
  },
  breaks: [{
    startTime: Date,
    endTime: Date,
    duration: Number // in minutes
  }],
  focusScore: {
    type: Number,
    min: 0,
    max: 100,
    default: 100
  },
  notes: {
    type: String,
    maxlength: [1000, 'Notes cannot be more than 1000 characters']
  },
  completed: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Calculate duration when session ends
studySessionSchema.pre('save', function(next) {
  if (this.endTime && this.startTime) {
    const totalMinutes = Math.floor((this.endTime - this.startTime) / (1000 * 60));
    const breakMinutes = this.breaks.reduce((sum, br) => sum + (br.duration || 0), 0);
    this.duration = totalMinutes - breakMinutes;
  }
  next();
});

const StudySession = mongoose.model('StudySession', studySessionSchema);

export default StudySession;
