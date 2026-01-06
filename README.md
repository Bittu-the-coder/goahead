# GoAhead - Student Study Planner 🚀

GoAhead is a comprehensive Flutter application designed to help students manage their study schedules, track progress, and stay focused. With features like custom study plans, a Pomodoro-style timer, and detailed statistics, GoAhead makes achieving academic goals easier.

## ✨ Key Features

*   **📅 Smart Study Plans**: Create custom plans or choose from templates. Auto-generates daily schedules based on your subjects.
*   **⏱️ Focus Timer**: Built-in study timer with "Study" and "Break" modes.
    *   **Background Persistence**: Timer continues to run and notify you even if the app is closed or minimized.
    *   **Native Countdown**: Uses Android Chronometer for battery-efficient, real-time notification updates.
*   **🔔 Intelligent Notifications**:
    *   Get reminded when a study task is scheduled to start.
    *   Receive alerts when your timer or break ends.
    *   Works reliably in the background using `android_alarm_manager_plus`.
*   **📊 Detailed Statistics**:
    *   Track daily, weekly, and monthly study time.
    *   Visualize consistency with a GitHub-style contribution heatmap.
    *   Earn badges for milestones (e.g., "Early Bird", "Night Owl").
*   **📝 Task Management**: Simple to-do list to keep track of assignments and extra tasks.
*   **🎨 Modern UI**: Clean, dark-themed interface built with Flutter.

## 📱 Screenshots

| Dashboard | Study Timer | Statistics |
|-----------|-------------|------------|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Timer](assets/screenshots/timer.png) | ![Stats](assets/screenshots/stats.png) |

*(Note: Add screenshots to `assets/screenshots/`)*

## 🛠️ Tech Stack

*   **Framework**: Flutter (Dart)
*   **State Management**: Provider
*   **Local Storage**: Hive & SharedPreferences
*   **Background Tasks**: `android_alarm_manager_plus`, `flutter_local_notifications`
*   **UI Components**: `fl_chart`, `table_calendar`, `google_fonts`

## 🚀 Installation

1.  **Download APK**: Get the latest release from the [Releases](https://github.com/yourusername/goahead/releases) page.
2.  **Install**: Open the `.apk` file on your Android device and allow installation from unknown sources if prompted.

## 👨‍💻 Development

To build the project locally:

1.  **Prerequisites**: Flutter SDK installed.
2.  **Clone**:
    ```bash
    git clone https://github.com/yourusername/goahead.git
    cd goahead
    ```
3.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Run**:
    ```bash
    flutter run
    ```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
Built with ❤️ by [Your Name]
