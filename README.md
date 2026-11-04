# Pockiva – Offline Flutter Savings Tracker

**Set a Goal. Make it Happen.**

Pockiva is a simple, offline-first Android savings tracker built with Flutter. It helps you create savings goals, track daily deposits, and monitor your progress — all without requiring an account, internet connection, or backend.

##   Download APK

[⬇️ **Download Pockiva for Android**](https://github.com/mhd-humraz/pockiva/releases/download/v1.0.0/app-release.apk)

Download the latest APK, install it on your Android device, and start tracking your savings!

> Android may ask you to allow installation from unknown sources when installing the APK.

##   Features

- **Multiple Savings Goals** – Create and manage multiple goals with a target amount, duration, and start date.
- **Flexible Savings Mode** – Record the actual amount you save each day.
- **Fixed Savings Plan** – Automatically divide your target into daily savings amounts.
- **Daily Tracking** – Record, edit, or uncheck daily savings entries.
- **Progress Dashboard** – View your total savings and individual goal progress.
- **Dark & Light Themes** – Switch between themes, with your preference saved locally.
- **Offline First** – Works without internet, accounts, or cloud services.
- **Local Data Storage** – Your savings records are stored on your device using SQLite.

##   Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Android app development |
| Dart | Programming language |
| SQLite | Local savings data storage |
| SharedPreferences | Theme preference storage |

##   Run Locally

### 1. Prerequisites

Install the following:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Android Studio](https://developer.android.com/studio)
- Android SDK

### 2. Clone the Repository

```bash
git clone https://github.com/mhd-humraz/pockiva.git
cd pockiva
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Application

Connect your Android device with USB debugging enabled, then run:

```bash
flutter devices
flutter run
```

You can also run the app using an Android emulator.

##   Build APK

Generate a release APK:

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

##   Data & Privacy

- No account or registration required.
- No backend, API, or cloud database.
- Savings goals and entries are stored locally in SQLite.
- Theme preferences are stored locally using SharedPreferences.
- No automatic synchronization between devices.

**Important:** Your savings data belongs to the local installation. Back up your data before changing devices or reinstalling the application.

##  Future Improvements

- Savings data export and restore.
- Database backup and recovery.
- More detailed savings analytics.
- Improved goal management.

##   License

This project is currently available for personal and educational use. Add a license file if you plan to distribute it under a specific open-source license.

---

**Pockiva – Set a Goal. Make it Happen.**