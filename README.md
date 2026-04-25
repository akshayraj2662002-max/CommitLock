# CommitLock

CommitLock is a cross-platform (Android, iOS, Web) Flutter accountability application designed to help users stay committed to their habits and avoid distractions. Users can start timed sessions, face penalties for breaking their commitments, and track their progress over time.

---

## 📸 App Screenshots

| Dashboard | New Commitment |

<img width="599" height="885" alt="image" src="https://github.com/user-attachments/assets/22806b46-c333-4c7d-983f-076da5e57136" />
<img width="622" height="910" alt="image" src="https://github.com/user-attachments/assets/44b4eb02-1b30-4532-9a21-dbb4791cdd02" />


| Active Session | Result Screen |
|:---:|:---:|
<img width="618" height="899" alt="image" src="https://github.com/user-attachments/assets/390ce86f-1ca3-4e35-8e40-55bef20fc432" />
<img width="619" height="911" alt="image" src="https://github.com/user-attachments/assets/6b2961ca-fb28-40fc-8d35-bf7f83a9ed34" />

| History | 
<img width="623" height="901" alt="image" src="https://github.com/user-attachments/assets/a18bdef8-5f99-4b7c-b451-b94cbba99ac7" />


---

## 🎯 Features Completed
- **Full Application Flow:** Splash screen, Login, Dashboard, New Commitment setup, Active Session tracker, and Result Screen.
- **Accountability & Penalties:** Users specify a required habit category, duration, "Restriction Level" (normal, strict, extreme), and a mock penalty amount.
- **Session Recovery Logic:** If the app is interrupted (e.g., killed or paused), the session timer and state automatically resume when the app reopens by recalculating time against the original start timestamp.
- **Local Persistence & Settings:** Sessions, history streaks, and settings (theme, notifications) are saved locally and persist across app reloads.
- **Interactive Timer:** A circular percent indicator accompanied by rotating motivational quotes keeps users engaged.

---

## 🏗️ Architecture & State Management

### State Management: `Provider`
The app utilizes the **Provider** package (`ChangeNotifierProvider`) for scalable and reactive state management. State is split logically:
- `AuthProvider`: Manages mock user login state.
- `SessionProvider`: Core engine for active sessions. Handles timers, session duration math, and recovering lost state.
- `HistoryProvider`: Fetches past sessions to display stats and logs.
- `SettingsProvider`: Manages user preferences (like Dark/Light mode).

### Architecture: Layered/Clean Architecture
The directory is logically divided into:
- **`core/`**: Constants, utility functions, and app themes.
- **`data/`**: Data Models (`session_model.dart`) and Datasources (`hive_datasource.dart`, `prefs_datasource.dart`).
- **`presentation/`**: Screens, widgets, and Providers. This ensures the UI is strictly separated from the data persistence layer.

### Local Database: `Hive` & `SharedPreferences`
- **Hive:** Used as a fast, lightweight NoSQL database to store complex objects (like `SessionModel`). Hive’s blazing-fast read/write operations make it ideal for quickly saving session states globally.
- **SharedPreferences:** Used for simple key-value pairs like current theme, app volume, and total streak count.

---

## ⚙️ Setup Instructions

### Prerequisites
- Flutter SDK (`>=3.9.2`)
- Xcode (for iOS build)
- Android Studio (for Android build)

### Running Locally
1. **Clone the repository and install dependencies:**
   ```bash
   flutter pub get
   ```
2. **Build necessary generated files for Hive (if modifying models):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. **Run the App:**
   ```bash
   flutter run
   ```

---

## 📱 Platform Support & iOS Build Overview

### Tested Platforms
This project has been tested and confirmed fully functional on **Android**, **Web**, and **iOS simulators**. End-to-end flows, layout adaptability, and local storage limits behave synchronously across platforms. 

### Generating an iOS Release Build
To generate an iOS release build for App Store deployment or Ad-Hoc testing, follow these steps:
1. Ensure your Flutter environment is ready:
   ```bash
   flutter build ios --release
   ```
2. Open the generated workspace in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Ensure the active scheme is set to "Runner" and target device is "Any iOS Device (arm64)".
4. Archive the application: **Product > Archive**.
5. Once the archive succeeds, the Organizer window will open, allowing you to validate and distribute the app to App Store Connect or generate an `.ipa`.

### iOS App Signing & Provisioning
iOS requires strict cryptographic signing. To build for iOS devices:
- **Apple Developer Account:** You must be enrolled in the Apple Developer Program.
- **Certificates:** You need an **iOS Distribution Certificate** (for App Store) or a **Development Certificate** (for local testing).
- **App ID:** Register your `PRODUCT_BUNDLE_IDENTIFIER` on the Apple Developer portal.
- **Provisioning Profile:** Download and link a provisioning profile that connects your App ID to your Certificate. These are configured directly in Xcode under the **Runner target > Signing & Capabilities**. Enable "Automatically manage signing" for ease during development.

### Proper `Info.plist` Configuration
If the app features are expanded later, iOS requires explicit keys to request user permission:
- **Notifications**: Not currently implemented beyond UI logic, but if integrated with APNS or Local Notifications, it requires no explicit Plist permission but does require user consent at runtime.
- If future iterations require Camera or FaceID (e.g., Extreme Restriction facial recognition), you **must** add:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>CommitLock requires the camera to verify you are currently at your desk.</string>
  <key>NSFaceIDUsageDescription</key>
  <string>CommitLock uses FaceID to lock the broken session screen.</string>
  ```
  *Failure to include proper usage descriptions will cause automatic App Store rejection.*

### Known Limitations
- The underlying "Blocked Categories" system is purely mock-only (Flutter cannot natively sandbox or block system-level apps dynamically on iOS without MDM/Screen Time APIs, which require very specific Entitlements and Apple approval).
- On iOS, `Timer.periodic` used in the app pauses completely when in the background. **Session Recovery** safely offsets this by storing the absolute `startTimestamp` and reconciling the duration when `didChangeAppLifecycleState` detects a return to the foreground.

---
*Developed with focus, precision, and zero broken commitments.*
