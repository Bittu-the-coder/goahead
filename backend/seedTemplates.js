import dotenv from 'dotenv';
import connectDB from './config/db.js';
import PlanTemplate from './models/PlanTemplate.js';

dotenv.config();

const templates = [
  {
    name: 'CAT Preparation - 6 Month Intensive',
    type: 'CAT',
    description: 'Comprehensive 6-month plan for Common Admission Test covering Quantitative Aptitude, Verbal Ability & Reading Comprehension, and Data Interpretation & Logical Reasoning.',
    duration: { weeks: 24, months: 6 },
    difficulty: 'advanced',
    subjects: [
      { name: 'Quantitative Aptitude', weeklyHours: 12, importance: 'high' },
      { name: 'Verbal Ability & RC', weeklyHours: 10, importance: 'high' },
      { name: 'Data Interpretation & LR', weeklyHours: 10, importance: 'high' },
      { name: 'Mock Tests', weeklyHours: 6, importance: 'high' }
    ],
    features: [
      'Daily practice sessions',
      'Weekly mock tests',
      'Sectional tests',
      'Previous year papers',
      'Time management strategies'
    ],
    tips: [
      'Focus on accuracy before speed',
      'Analyze every mock test thoroughly',
      'Maintain error log for weak areas',
      'Read newspapers daily for RC prep'
    ],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'Quantitative Aptitude', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Arithmetic', 'Algebra'], priority: 'high' },
          { name: 'Verbal Ability', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Grammar', 'Vocabulary'], priority: 'medium' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'Data Interpretation', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Tables', 'Graphs'], priority: 'high' },
          { name: 'Logical Reasoning', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Puzzles', 'Arrangements'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Quantitative Aptitude', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Geometry', 'Number System'], priority: 'high' },
          { name: 'Reading Comprehension', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Practice passages'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'Data Interpretation', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Caselets', 'Charts'], priority: 'high' },
          { name: 'Verbal Ability', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Para jumbles', 'Critical reasoning'], priority: 'medium' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'Quantitative Aptitude', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Modern Math', 'Mensuration'], priority: 'high' },
          { name: 'Logical Reasoning', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Syllogisms', 'Blood relations'], priority: 'medium' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Mock Test', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Full length test'], priority: 'high' },
          { name: 'Mock Analysis', startTime: '14:00', endTime: '17:00', duration: 180, topics: ['Review and improvement'], priority: 'high' }
        ],
        totalHours: 6,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Revision', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Week review'], priority: 'medium' },
          { name: 'Previous Year Papers', startTime: '14:00', endTime: '16:00', duration: 120, topics: ['Practice'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 60
      }
    ]
  },
  {
    name: 'GMAT Preparation - 3 Month Plan',
    type: 'GMAT',
    description: 'Intensive 3-month GMAT preparation covering Quantitative, Verbal, Integrated Reasoning, and Analytical Writing Assessment.',
    duration: { weeks: 12, months: 3 },
    difficulty: 'advanced',
    subjects: [
      { name: 'Quantitative Reasoning', weeklyHours: 10, importance: 'high' },
      { name: 'Verbal Reasoning', weeklyHours: 10, importance: 'high' },
      { name: 'Integrated Reasoning', weeklyHours: 6, importance: 'medium' },
      { name: 'AWA', weeklyHours: 4, importance: 'medium' }
    ],
    features: ['Official GMAT prep', 'Practice tests', 'Time management', 'Strategy sessions'],
    tips: ['Focus on official materials', 'Practice under timed conditions', 'Review error log daily'],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'Quantitative Reasoning', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Problem Solving'], priority: 'high' },
          { name: 'Verbal Reasoning', startTime: '19:00', endTime: '21:00', duration: 120, topics: ['Critical Reasoning'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'Quantitative Reasoning', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Data Sufficiency'], priority: 'high' },
          { name: 'Verbal Reasoning', startTime: '19:00', endTime: '21:00', duration: 120, topics: ['Reading Comprehension'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Integrated Reasoning', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Multi-source reasoning'], priority: 'medium' },
          { name: 'AWA', startTime: '19:00', endTime: '20:30', duration: 90, topics: ['Essay practice'], priority: 'medium' }
        ],
        totalHours: 3.5,
        breakTime: 30
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'Quantitative Reasoning', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Mixed practice'], priority: 'high' },
          { name: 'Verbal Reasoning', startTime: '19:00', endTime: '21:00', duration: 120, topics: ['Sentence Correction'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'Integrated Reasoning', startTime: '06:00', endTime: '07:30', duration: 90, topics: ['Graphics interpretation'], priority: 'medium' },
          { name: 'Revision', startTime: '19:00', endTime: '21:00', duration: 120, topics: ['Week review'], priority: 'medium' }
        ],
        totalHours: 3.5,
        breakTime: 30
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Full Mock Test', startTime: '09:00', endTime: '12:30', duration: 210, topics: ['Complete GMAT'], priority: 'high' },
          { name: 'Test Analysis', startTime: '14:00', endTime: '17:00', duration: 180, topics: ['Review'], priority: 'high' }
        ],
        totalHours: 6.5,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Weak Areas', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Focused practice'], priority: 'high' }
        ],
        totalHours: 3,
        breakTime: 30
      }
    ]
  },
  {
    name: 'UPSC Civil Services - 12 Month Comprehensive',
    type: 'UPSC',
    description: 'Year-long comprehensive plan for UPSC Civil Services covering Prelims and Mains with current affairs integration.',
    duration: { weeks: 52, months: 12 },
    difficulty: 'advanced',
    subjects: [
      { name: 'History', weeklyHours: 8, importance: 'high' },
      { name: 'Geography', weeklyHours: 6, importance: 'high' },
      { name: 'Polity', weeklyHours: 8, importance: 'high' },
      { name: 'Economy', weeklyHours: 6, importance: 'high' },
      { name: 'Current Affairs', weeklyHours: 7, importance: 'high' },
      { name: 'Optional Subject', weeklyHours: 10, importance: 'high' }
    ],
    features: ['NCERT foundation', 'Standard books', 'Answer writing', 'Current affairs daily', 'Test series'],
    tips: ['Read newspaper daily', 'Make concise notes', 'Practice answer writing', 'Revise regularly'],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'History', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Ancient India'], priority: 'high' },
          { name: 'Current Affairs', startTime: '20:00', endTime: '21:00', duration: 60, topics: ['Daily news'], priority: 'high' }
        ],
        totalHours: 3,
        breakTime: 30
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'Geography', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Physical Geography'], priority: 'high' },
          { name: 'Current Affairs', startTime: '20:00', endTime: '21:00', duration: 60, topics: ['Daily news'], priority: 'high' }
        ],
        totalHours: 3,
        breakTime: 30
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Polity', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Constitution'], priority: 'high' },
          { name: 'Current Affairs', startTime: '20:00', endTime: '21:00', duration: 60, topics: ['Daily news'], priority: 'high' }
        ],
        totalHours: 3,
        breakTime: 30
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'Economy', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Indian Economy'], priority: 'high' },
          { name: 'Current Affairs', startTime: '20:00', endTime: '21:00', duration: 60, topics: ['Daily news'], priority: 'high' }
        ],
        totalHours: 3,
        breakTime: 30
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'Optional Subject', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Core topics'], priority: 'high' },
          { name: 'Current Affairs', startTime: '20:00', endTime: '21:00', duration: 60, topics: ['Weekly review'], priority: 'high' }
        ],
        totalHours: 3,
        breakTime: 30
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Answer Writing', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Mains practice'], priority: 'high' },
          { name: 'Optional Subject', startTime: '14:00', endTime: '17:00', duration: 180, topics: ['Advanced topics'], priority: 'high' }
        ],
        totalHours: 6,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Revision', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Week review'], priority: 'medium' },
          { name: 'Test Series', startTime: '14:00', endTime: '16:00', duration: 120, topics: ['Practice'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 60
      }
    ]
  },
  {
    name: 'JEE Preparation - 1 Year Plan',
    type: 'JEE',
    description: 'Comprehensive 1-year plan for JEE Main and Advanced covering Physics, Chemistry, and Mathematics.',
    duration: { weeks: 52, months: 12 },
    difficulty: 'advanced',
    subjects: [
      { name: 'Physics', weeklyHours: 15, importance: 'high' },
      { name: 'Chemistry', weeklyHours: 15, importance: 'high' },
      { name: 'Mathematics', weeklyHours: 15, importance: 'high' }
    ],
    features: ['NCERT mastery', 'Problem solving', 'Mock tests', 'Previous year papers', 'Concept clarity'],
    tips: ['Master NCERT first', 'Practice numericals daily', 'Solve previous years', 'Time management in tests'],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'Physics', startTime: '06:00', endTime: '08:30', duration: 150, topics: ['Mechanics'], priority: 'high' },
          { name: 'Mathematics', startTime: '16:00', endTime: '18:30', duration: 150, topics: ['Calculus'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'Chemistry', startTime: '06:00', endTime: '08:30', duration: 150, topics: ['Physical Chemistry'], priority: 'high' },
          { name: 'Physics', startTime: '16:00', endTime: '18:30', duration: 150, topics: ['Electromagnetism'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Mathematics', startTime: '06:00', endTime: '08:30', duration: 150, topics: ['Algebra'], priority: 'high' },
          { name: 'Chemistry', startTime: '16:00', endTime: '18:30', duration: 150, topics: ['Organic Chemistry'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'Physics', startTime: '06:00', endTime: '08:30', duration: 150, topics: ['Modern Physics'], priority: 'high' },
          { name: 'Mathematics', startTime: '16:00', endTime: '18:30', duration: 150, topics: ['Coordinate Geometry'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'Chemistry', startTime: '06:00', endTime: '08:30', duration: 150, topics: ['Inorganic Chemistry'], priority: 'high' },
          { name: 'Revision', startTime: '16:00', endTime: '18:00', duration: 120, topics: ['Week review'], priority: 'medium' }
        ],
        totalHours: 4.5,
        breakTime: 30
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Full Mock Test', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['JEE pattern'], priority: 'high' },
          { name: 'Test Analysis', startTime: '14:00', endTime: '17:00', duration: 180, topics: ['Review'], priority: 'high' }
        ],
        totalHours: 6,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Previous Year Papers', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Practice'], priority: 'high' },
          { name: 'Doubt Clearing', startTime: '14:00', endTime: '16:00', duration: 120, topics: ['Concepts'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 60
      }
    ]
  },
  {
    name: 'NEET Preparation - 1 Year Plan',
    type: 'NEET',
    description: 'Comprehensive medical entrance preparation covering Physics, Chemistry, and Biology with NCERT focus.',
    duration: { weeks: 52, months: 12 },
    difficulty: 'advanced',
    subjects: [
      { name: 'Physics', weeklyHours: 12, importance: 'high' },
      { name: 'Chemistry', weeklyHours: 12, importance: 'high' },
      { name: 'Biology', weeklyHours: 18, importance: 'high' }
    ],
    features: ['NCERT line by line', 'Diagrams practice', 'Mock tests', 'Previous year analysis'],
    tips: ['NCERT is the bible', 'Practice diagrams', 'Revise biology daily', 'Time management'],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'Biology', startTime: '06:00', endTime: '09:00', duration: 180, topics: ['Botany'], priority: 'high' },
          { name: 'Physics', startTime: '16:00', endTime: '18:00', duration: 120, topics: ['Mechanics'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'Biology', startTime: '06:00', endTime: '09:00', duration: 180, topics: ['Zoology'], priority: 'high' },
          { name: 'Chemistry', startTime: '16:00', endTime: '18:00', duration: 120, topics: ['Physical Chemistry'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Biology', startTime: '06:00', endTime: '09:00', duration: 180, topics: ['Human Physiology'], priority: 'high' },
          { name: 'Physics', startTime: '16:00', endTime: '18:00', duration: 120, topics: ['Optics'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'Biology', startTime: '06:00', endTime: '09:00', duration: 180, topics: ['Genetics'], priority: 'high' },
          { name: 'Chemistry', startTime: '16:00', endTime: '18:00', duration: 120, topics: ['Organic Chemistry'], priority: 'high' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'Biology', startTime: '06:00', endTime: '09:00', duration: 180, topics: ['Ecology'], priority: 'high' },
          { name: 'Revision', startTime: '16:00', endTime: '18:00', duration: 120, topics: ['Week review'], priority: 'medium' }
        ],
        totalHours: 5,
        breakTime: 30
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Full Mock Test', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['NEET pattern'], priority: 'high' },
          { name: 'Test Analysis', startTime: '14:00', endTime: '17:00', duration: 180, topics: ['Review'], priority: 'high' }
        ],
        totalHours: 6,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Previous Year Papers', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Practice'], priority: 'high' },
          { name: 'Biology Revision', startTime: '14:00', endTime: '17:00', duration: 180, topics: ['NCERT'], priority: 'high' }
        ],
        totalHours: 6,
        breakTime: 60
      }
    ]
  },
  {
    name: 'SSC Preparation - 6 Month Plan',
    type: 'SSC',
    description: 'Staff Selection Commission preparation covering Reasoning, Quantitative Aptitude, English, and General Knowledge.',
    duration: { weeks: 24, months: 6 },
    difficulty: 'intermediate',
    subjects: [
      { name: 'Reasoning', weeklyHours: 8, importance: 'high' },
      { name: 'Quantitative Aptitude', weeklyHours: 10, importance: 'high' },
      { name: 'English', weeklyHours: 8, importance: 'high' },
      { name: 'General Knowledge', weeklyHours: 8, importance: 'high' }
    ],
    features: ['Previous year papers', 'Speed and accuracy', 'Current affairs', 'Mock tests'],
    tips: ['Practice speed', 'Read newspapers', 'Solve previous years', 'Time management'],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'Reasoning', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Verbal reasoning'], priority: 'high' },
          { name: 'Quantitative Aptitude', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Arithmetic'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'English', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Grammar'], priority: 'high' },
          { name: 'General Knowledge', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Current affairs'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Reasoning', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Non-verbal reasoning'], priority: 'high' },
          { name: 'Quantitative Aptitude', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Algebra'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'English', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Comprehension'], priority: 'high' },
          { name: 'General Knowledge', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Static GK'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'Quantitative Aptitude', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Geometry'], priority: 'high' },
          { name: 'Revision', startTime: '18:00', endTime: '20:00', duration: 120, topics: ['Week review'], priority: 'medium' }
        ],
        totalHours: 4,
        breakTime: 30
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Full Mock Test', startTime: '09:00', endTime: '11:00', duration: 120, topics: ['SSC pattern'], priority: 'high' },
          { name: 'Test Analysis', startTime: '14:00', endTime: '16:00', duration: 120, topics: ['Review'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Previous Year Papers', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Practice'], priority: 'high' }
        ],
        totalHours: 3,
        breakTime: 30
      }
    ]
  },
  {
    name: 'DSA Interview Prep - 3 Month Coding Plan',
    type: 'DSA',
    description: 'Data Structures and Algorithms preparation for technical interviews with LeetCode pattern-based approach.',
    duration: { weeks: 12, months: 3 },
    difficulty: 'intermediate',
    subjects: [
      { name: 'Arrays & Strings', weeklyHours: 8, importance: 'high' },
      { name: 'Trees & Graphs', weeklyHours: 8, importance: 'high' },
      { name: 'Dynamic Programming', weeklyHours: 6, importance: 'high' },
      { name: 'System Design', weeklyHours: 4, importance: 'medium' }
    ],
    features: ['LeetCode patterns', 'Mock interviews', 'System design', 'Time complexity analysis'],
    tips: ['Understand patterns', 'Practice daily', 'Explain your approach', 'Time yourself'],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'Arrays & Strings', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Two pointers', 'Sliding window'], priority: 'high' },
          { name: 'Practice', startTime: '20:00', endTime: '21:30', duration: 90, topics: ['LeetCode easy'], priority: 'high' }
        ],
        totalHours: 3.5,
        breakTime: 30
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'Trees & Graphs', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['BFS', 'DFS'], priority: 'high' },
          { name: 'Practice', startTime: '20:00', endTime: '21:30', duration: 90, topics: ['LeetCode medium'], priority: 'high' }
        ],
        totalHours: 3.5,
        breakTime: 30
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Dynamic Programming', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['1D DP'], priority: 'high' },
          { name: 'Practice', startTime: '20:00', endTime: '21:30', duration: 90, topics: ['DP problems'], priority: 'high' }
        ],
        totalHours: 3.5,
        breakTime: 30
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'Arrays & Strings', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Advanced patterns'], priority: 'high' },
          { name: 'Practice', startTime: '20:00', endTime: '21:30', duration: 90, topics: ['LeetCode hard'], priority: 'high' }
        ],
        totalHours: 3.5,
        breakTime: 30
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'System Design', startTime: '06:00', endTime: '08:00', duration: 120, topics: ['Scalability'], priority: 'medium' },
          { name: 'Revision', startTime: '20:00', endTime: '21:30', duration: 90, topics: ['Week review'], priority: 'medium' }
        ],
        totalHours: 3.5,
        breakTime: 30
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Mock Interview', startTime: '10:00', endTime: '12:00', duration: 120, topics: ['Coding round'], priority: 'high' },
          { name: 'Review', startTime: '14:00', endTime: '16:00', duration: 120, topics: ['Analysis'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Contest', startTime: '10:00', endTime: '12:00', duration: 120, topics: ['LeetCode weekly'], priority: 'high' },
          { name: 'Weak Topics', startTime: '14:00', endTime: '16:00', duration: 120, topics: ['Practice'], priority: 'high' }
        ],
        totalHours: 4,
        breakTime: 60
      }
    ]
  },
  {
    name: 'General Productivity - Flexible Daily Routine',
    type: 'General',
    description: 'Balanced productivity plan for skill development, work-life balance, and personal growth.',
    duration: { weeks: 12, months: 3 },
    difficulty: 'beginner',
    subjects: [
      { name: 'Skill Development', weeklyHours: 10, importance: 'high' },
      { name: 'Reading', weeklyHours: 5, importance: 'medium' },
      { name: 'Exercise', weeklyHours: 5, importance: 'high' },
      { name: 'Personal Projects', weeklyHours: 8, importance: 'medium' }
    ],
    features: ['Flexible schedule', 'Habit tracking', 'Goal setting', 'Work-life balance'],
    tips: ['Start small', 'Be consistent', 'Track progress', 'Adjust as needed'],
    weeklySchedule: [
      {
        day: 'Monday',
        subjects: [
          { name: 'Skill Development', startTime: '06:00', endTime: '07:30', duration: 90, topics: ['Online courses'], priority: 'high' },
          { name: 'Exercise', startTime: '18:00', endTime: '19:00', duration: 60, topics: ['Workout'], priority: 'high' }
        ],
        totalHours: 2.5,
        breakTime: 15
      },
      {
        day: 'Tuesday',
        subjects: [
          { name: 'Reading', startTime: '06:00', endTime: '07:00', duration: 60, topics: ['Books'], priority: 'medium' },
          { name: 'Personal Projects', startTime: '19:00', endTime: '21:00', duration: 120, topics: ['Side projects'], priority: 'medium' }
        ],
        totalHours: 3,
        breakTime: 15
      },
      {
        day: 'Wednesday',
        subjects: [
          { name: 'Skill Development', startTime: '06:00', endTime: '07:30', duration: 90, topics: ['Practice'], priority: 'high' },
          { name: 'Exercise', startTime: '18:00', endTime: '19:00', duration: 60, topics: ['Cardio'], priority: 'high' }
        ],
        totalHours: 2.5,
        breakTime: 15
      },
      {
        day: 'Thursday',
        subjects: [
          { name: 'Reading', startTime: '06:00', endTime: '07:00', duration: 60, topics: ['Articles'], priority: 'medium' },
          { name: 'Personal Projects', startTime: '19:00', endTime: '21:00', duration: 120, topics: ['Development'], priority: 'medium' }
        ],
        totalHours: 3,
        breakTime: 15
      },
      {
        day: 'Friday',
        subjects: [
          { name: 'Skill Development', startTime: '06:00', endTime: '07:30', duration: 90, topics: ['Review'], priority: 'high' },
          { name: 'Exercise', startTime: '18:00', endTime: '19:00', duration: 60, topics: ['Strength training'], priority: 'high' }
        ],
        totalHours: 2.5,
        breakTime: 15
      },
      {
        day: 'Saturday',
        subjects: [
          { name: 'Personal Projects', startTime: '09:00', endTime: '12:00', duration: 180, topics: ['Deep work'], priority: 'high' },
          { name: 'Reading', startTime: '15:00', endTime: '17:00', duration: 120, topics: ['Long form'], priority: 'medium' }
        ],
        totalHours: 5,
        breakTime: 60
      },
      {
        day: 'Sunday',
        subjects: [
          { name: 'Planning', startTime: '09:00', endTime: '10:00', duration: 60, topics: ['Week ahead'], priority: 'medium' },
          { name: 'Reflection', startTime: '20:00', endTime: '21:00', duration: 60, topics: ['Review'], priority: 'low' }
        ],
        totalHours: 2,
        breakTime: 30
      }
    ]
  }
];

const seedTemplates = async () => {
  try {
    await connectDB();

    // Clear existing templates
    await PlanTemplate.deleteMany({});
    console.log('Cleared existing templates');

    // Insert new templates
    const created = await PlanTemplate.insertMany(templates);
    console.log(`✅ Successfully seeded ${created.length} templates:`);
    created.forEach(t => console.log(`   - ${t.name} (${t.type})`));

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding templates:', error);
    process.exit(1);
  }
};

seedTemplates();
