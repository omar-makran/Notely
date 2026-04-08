# Notely 📝

**Your notes, anywhere.**

Notely is a beautifully crafted, highly-responsive cross-platform note-taking application built with Flutter. It focuses on delivering a premium, iOS-native feel featuring smooth micro-animations, glassmorphism aesthetics, and real-time cloud synchronization.

## ✨ Features

- **Beautiful Authentication Flow**: Seamless login, registration, and email verification screens powered by dynamic `TweenAnimationBuilder` entrance animations.
- **Premium UI/UX**: 
  - Dynamic iOS-style `SliverAppBar.large` rolling headers.
  - Native iOS glassmorphism (frosted glass) effects on contextual buttons.
  - Silky smooth swipe-to-action (Share & Delete) using `flutter_slidable`.
- **Real-Time Cloud Sync**: Notes instantly sync across your devices via Firebase Cloud Firestore.
- **Robust State Management**: Powered by the **BLoC** (Business Logic Component) pattern for incredibly predictable authentication and app states.
- **Dark Mode Ready**: Fully adheres to native Material Design 3 surface colors and adapts flawlessly to system dark/light modes.

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev)
- **Backend:** [Firebase](https://firebase.google.com) (Authentication, Cloud Firestore)
- **State Management:** `flutter_bloc`
- **UI Architecture:** Material 3 & Custom Cupertino Elements

---

## 🚀 Getting Started

To run Notely locally, you'll need to set up your own Firebase project.

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- [Firebase CLI](https://firebase.google.com/docs/cli) installed.

### 2. Clone the Repository
```bash
git clone https://github.com/omar-makran/Notely
cd notely
flutter pub get
```

### 3. Firebase Setup
Since Firebase configuration files are intentionally ignored in this repository for security, you must connect it to your own Firebase project:

1. Create a project at the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password Authentication** and **Firestore Database**.
3. Run the following command in the root directory to generate your config:
```bash
flutterfire configure
```
*(This commands generates `firebase_options.dart`, `google-services.json`, and `GoogleService-Info.plist` automatically based on your project.)*

### 4. Run the App
```bash
flutter run
```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
_Designed and built with Flutter._
