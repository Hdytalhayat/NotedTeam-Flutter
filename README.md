# NotedTeam - Mobile Apps (Flutter)

<img src="assets/images/LOGO-BG.png" alt="NotedTeam Logo" width="160"/>

This is the mobile application repository for **NotedTeam**, a collaborative to-do list app built using **Flutter**. It serves as the frontend interface for the [NotedTeam Go Backend](https://github.com/Hdytalhayat/NotedTeamBackend).

Designed to provide a smooth, responsive, and real-time experience on Android devices.

[**Visit Landing Page »**](https://github.com/Hdytalhayat/NotedTeam)

---

## 📱 App Features

- **Clean & Modern Interface**: Beautiful UI with full support for Light & Dark modes.
- **Complete Authentication Flow**:
  - User Registration with Email Verification.
  - Secure Login using JWT.
  - Forgot & Reset Password functionality.
  - Persistent sessions (Auto-login).
- **Collaborative Team Management**:
  - Create, rename, and delete teams (owner only).
  - Invite members via email.
  - Accept or decline team invitations.
  - View team members.
- **Interactive Task Management**:
  - Full CRUD support for to-do items.
  - Swipe-to-delete functionality.
  - Status, Urgency, and Due Date settings.
- **Real-Time Synchronization**: Powered by **WebSocket**, all to-do list updates are instantly pushed to all online team members.
- **Internationalization (i18n)**: Support for English and Indonesian languages.
- **Persistent Settings**: Users can store their preferred theme and language locally.

## 🛠️ Tech Stack & Architecture

- **Framework**: **Flutter 3.x**
- **Language**: **Dart**
- **State Management**: **Provider** – Widely adopted reactive state management pattern using `ChangeNotifierProvider` and `ChangeNotifierProxyProvider` for dependencies.
- **Networking**:
  - `http`: For RESTful API communication with the backend.
  - `web_socket_channel`: For real-time WebSocket connections.
- **Local Storage**: `shared_preferences` to persist JWT tokens and user settings.
- **Navigation**: Uses Flutter's built-in `Navigator` with `MaterialPageRoute` and `pushAndRemoveUntil` for solid auth flows.
- **Localization**: `flutter_localizations` and `intl` with `.arb` files for managing translations.
- **Additional UI Dependencies**:
  - `google_fonts`: For consistent and attractive typography.
  - `flutter_staggered_animations`: For smooth list animations.

## 📂 Project Structure

The project follows a layered architecture for readability and scalability:

```

lib/
├── api/          # Backend communication layer (Services)
│   ├── api\_service.dart
│   ├── auth\_service.dart
│   └── websocket\_service.dart
├── l10n/         # Translation files (i18n)
│   ├── app\_en.arb
│   └── app\_id.arb
├── models/       # Data models representing JSON structures
│   ├── invitation.dart
│   ├── team.dart
│   ├── todo.dart
│   └── user.dart
├── providers/    # Business logic and state management
│   ├── auth\_provider.dart
│   ├── settings\_provider.dart
│   └── team\_provider.dart
├── screens/      # UI pages/screens
│   ├── home\_screen.dart
│   ├── invitations\_screen.dart
│   ├── login\_screen.dart
│   ├── register\_screen.dart
│   ├── settings\_screen.dart
│   └── todo\_screen.dart
└── main.dart     # Main entry point, sets up providers and theming

````

## 🚀 Getting Started

### Prerequisites

- Install **Flutter SDK** (version 3.0 or later).
- **NotedTeam Backend must be running**. See [backend documentation]([Link to Your Backend Repository Here]) for instructions.

### Installation & Running

1. **Clone this repository:**
    ```bash
    git clone [Your Frontend Repository Link Here]
    cd notedteam_app
    ```

2. **Install all dependencies:**
    ```bash
    flutter pub get
    ```

3. **Configure Backend URL:**
    - Open `lib/api/api_service.dart`
    - Locate the `_baseUrl` variable.
    - Set it according to your backend address:
        - For Android emulator: `'http://10.0.2.2:8080'`
        - For iOS simulator: `'http://localhost:8080'`
        - For physical devices (on the same network): `'http://[YOUR_LOCAL_IP]:8080'`
    - Do the same for WebSocket URL in `lib/api/websocket_service.dart`.

4. **Run the app (Debug mode):**
    ```bash
    flutter run
    ```

## 📦 Building for Release

The app is set up to build an **Android App Bundle (AAB)** for publishing on the Google Play Store.

1. **Generate Signing Keystore**: Follow Flutter's official guide for [creating an upload keystore](https://docs.flutter.dev/deployment/android#create-an-upload-keystore).
2. **Configure `key.properties`**: Create a file at `android/key.properties` and add your keystore credentials. Make sure it’s listed in `.gitignore`.
3. **Update Versioning**: Increment `versionCode` and `versionName` in `android/app/build.gradle`.
4. **Build the AAB**:
    ```bash
    flutter build appbundle
    ```
    The release file will be located at: `build/app/outputs/bundle/release/app-release.aab`.

---
