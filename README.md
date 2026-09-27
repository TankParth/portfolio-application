# portfolio

Parth Tank portfolio app

## Download an Android APK

The `Build Android APK` GitHub Actions workflow builds the app on every push to
`main`. You can also start it manually from **Actions → Build Android APK → Run
workflow**.

After the run succeeds, open it and download **portfolio-android-apk** from the
Artifacts section. Extract the ZIP to get `app-release.apk`.

The current release configuration uses a debug signing key. These APKs are for
testing; configure a persistent release signing key before distributing the app
or publishing it to Google Play. Independent CI builds can use different debug
keys, so installing a later APK over an earlier one may require uninstalling the
earlier app (which removes its local data).

To build locally with Flutter and the Android SDK installed:

```sh
flutter pub get
flutter test
flutter build apk --release
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
