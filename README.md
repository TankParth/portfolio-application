# Parth Tank — Portfolio (Android app)

A Flutter app that wraps the live portfolio at **https://parthtankdev.vercel.app** in a
native shell: animated intro, a section dock synced to the page through a JavaScript
bridge, theme-aware native UI that remembers the last theme, a quick-actions sheet and an
offline screen.

The site is **not bundled** — the app loads it live, so website deploys reach the app with
no new APK. Only changes to the app itself need a new build. The website repo's
`AGENTS.md` (github.com/TankParth/personnel-portfolio) lists the few website changes that
also need an app change.

## Download

**Latest APK:** https://github.com/TankParth/portfolio-application/releases/latest/download/parth-tank-portfolio.apk

The `Build Android APK` workflow (`.github/workflows/build-apk.yml`) runs on every push to
`main` — or manually from **Actions → Build Android APK → Run workflow**. It analyzes,
tests and builds the APK, then publishes it as a GitHub Release (`build-<run number>`),
which the link above always points to. The APK is also kept as a 30-day run artifact.

Each build's run number becomes the Android `versionCode`, so a newer APK installs as an
update over an older one — **as long as both are signed with the same key** (below).

## Release signing

Without a key, CI signs with a throwaway debug key that differs on every run, so users
would have to uninstall before installing a newer APK. To sign with your own key:

1. Create an upload keystore once, and keep it (and its passwords) somewhere safe —
   losing it means future builds can't update installed apps:

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   (`keytool` ships with Android Studio: `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`.)

2. Base64-encode it, e.g. in PowerShell:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
   ```

3. In **GitHub → Settings → Secrets and variables → Actions**, add:

   | Secret | Value |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | the base64 text from step 2 |
   | `ANDROID_KEYSTORE_PASSWORD` | the keystore password |
   | `ANDROID_KEY_ALIAS` | `upload` (or the alias you chose) |
   | `ANDROID_KEY_PASSWORD` | the key password |

The next build is then signed with your key. To sign local builds too, put the keystore
at `android/app/upload-keystore.jks` and create `android/key.properties`:

```properties
storeFile=upload-keystore.jks
storePassword=…
keyAlias=upload
keyPassword=…
```

Both files are gitignored.

## Build locally

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`.

To try **unreleased website changes** inside the app, serve the website locally (e.g. on
port 5501) and build a debug APK pointed at it:

```sh
adb reverse tcp:5501 tcp:5501
flutter build apk --debug --dart-define=SITE_URL=http://localhost:5501
```

## Project layout

```
lib/
  config.dart          site URL, links, user-agent marker, timings
  theme.dart           SitePalette (built live from the site's CSS tokens) + presets
  theme_store.dart     remembers the last theme between launches
  site_bridge.dart     JS bridge: section + theme tokens → app, scrollTo → page
  screens/portfolio_screen.dart
  widgets/             intro, section dock, PT orb, quick-actions sheet, offline view, particles
```
