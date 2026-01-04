# FocusFlow - Flutter Productivity App

A comprehensive productivity mobile application built with Flutter for students preparing for exams and individuals seeking to optimize their time management.

## Features

✅ **Task Management**
- Create, edit, and delete tasks
- Priority levels (Low, Medium, High)
- Task filtering (All, Active, Completed)
- Due dates and categories

✅ **Pomodoro Study Timer**
- 25-minute focus sessions
- 5-minute break periods
- Subject and topic tracking
- Automatic session logging

✅ **Goal Tracking**
- Set goals with target dates
- Progress tracking (0-100%)
- Multiple categories (Daily, Weekly, Monthly, Exam, Custom)
- Milestone management

✅ **Dashboard**
- Quick stats overview
- Recent tasks display
- Study time tracking
- Goal progress summary

✅ **Dark Theme UI**
- Professional dark color scheme
- Glassmorphism effects
- Smooth animations
- Clean, modern design

## Tech Stack

- **Frontend**: Flutter
- **State Management**: Provider
- **Local Storage**: Hive
- **HTTP Client**: http package
- **Charts**: FL Chart
- **Fonts**: Google Fonts (Inter)
- **Backend**: Node.js + Express + MongoDB (see backend folder)

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Node.js and MongoDB (for backend)

## Installation

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd goahead
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Set Up Backend

Navigate to the backend folder and install dependencies:

```bash
cd backend
npm install
```

Create a `.env` file in the backend folder:

```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/focusflow
JWT_SECRET=your_secret_key_here
JWT_EXPIRE=7d
CLIENT_URL=http://localhost:5173
```

Start MongoDB and run the backend server:

```bash
npm run dev
```

### 4. Configure API URL

If running on a physical device, update the API URL in `lib/config/constants.dart`:

```dart
static const String apiBaseUrl = 'http://YOUR_LOCAL_IP:5000/api';
```

For Android emulator, use: `http://10.0.2.2:5000/api`

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── config/
│   ├── constants.dart      # App constants and API URLs
│   └── theme.dart          # Dark theme configuration
├── models/
│   ├── user.dart           # User model
│   ├── task.dart           # Task model
│   ├── study_session.dart  # Study session model
│   └── goal.dart           # Goal model
├── services/
│   ├── api_service.dart    # HTTP client
│   ├── auth_service.dart   # Authentication
│   ├── task_service.dart   # Task operations
│   ├── session_service.dart # Session operations
│   ├── goal_service.dart   # Goal operations
│   └── storage_service.dart # Local storage
├── providers/
│   ├── auth_provider.dart  # Auth state management
│   ├── task_provider.dart  # Task state management
│   └── goal_provider.dart  # Goal state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── dashboard_screen.dart
│   ├── tasks/
│   │   └── tasks_screen.dart
│   ├── study/
│   │   └── study_timer_screen.dart
│   └── goals/
│       └── goals_screen.dart
├── utils/
│   ├── date_helpers.dart   # Date formatting utilities
│   └── validators.dart     # Form validators
└── main.dart               # App entry point
```

## Usage

### 1. Register/Login
- Open the app and create a new account
- Or login with existing credentials

### 2. Create Tasks
- Navigate to Tasks tab
- Tap the + button
- Fill in task details (title, description, priority)
- Save the task

### 3. Start Study Session
- Go to Study tab
- Enter subject and topic
- Tap Start to begin 25-minute Pomodoro session
- Take breaks when timer completes

### 4. Set Goals
- Navigate to Goals tab
- Tap + to create a new goal
- Set title, description, category, and target date
- Track progress over time

## API Endpoints

The app connects to the following backend endpoints:

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user
- `GET /api/tasks` - Get all tasks
- `POST /api/tasks` - Create task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `PATCH /api/tasks/:id/complete` - Toggle task completion
- `GET /api/sessions` - Get study sessions
- `POST /api/sessions` - Create session
- `GET /api/sessions/stats` - Get statistics
- `GET /api/goals` - Get all goals
- `POST /api/goals` - Create goal
- `PUT /api/goals/:id` - Update goal
- `PATCH /api/goals/:id/progress` - Update progress

## Troubleshooting

### Backend Connection Issues

If the app can't connect to the backend:

1. Ensure the backend server is running
2. Check the API URL in `lib/config/constants.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. For physical devices, use your computer's local IP address

### Dependencies Issues

If you encounter dependency conflicts:

```bash
flutter clean
flutter pub get
```

## Future Enhancements

- [ ] Analytics screen with charts
- [ ] Session provider for better timer state management
- [ ] Offline mode with data synchronization
- [ ] Push notifications for task reminders
- [ ] Dark/Light theme toggle
- [ ] Export data functionality

## License

MIT License

## Author

Built with ❤️ using Flutter
