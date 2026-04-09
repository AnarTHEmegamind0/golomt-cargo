# core

Flutter app skeleton using `provider` with a simple feature-based structure:
fake authentication, a tabbed shell, profile loading, and theme settings.

## Requirements

- Flutter SDK (Dart `>=3.10.4`, per `pubspec.yaml`)

## Run

```bash
flutter pub get
flutter run
```

## Test / Lint

```bash
flutter test
flutter analyze
```

## Android APK Release

The Android project is now set up for a proper signed release APK. The simplest way to host and share test builds from this repo is GitHub Releases, because each workflow run can publish an `.apk` asset with a permanent download URL.

### 1. Create a release keystore once

```bash
keytool -genkeypair \
  -v \
  -keystore mobile/android/upload-keystore.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

If you want to build locally, copy `mobile/android/key.properties.example` to `mobile/android/key.properties` and fill in the same values you used for the keystore:

```properties
storeFile=upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Then build:

```bash
cd mobile
flutter build apk --release
```

### 2. Add GitHub repository secrets

In GitHub, open `Settings` -> `Secrets and variables` -> `Actions` and add:

- `ANDROID_KEYSTORE_BASE64`: base64 of `mobile/android/upload-keystore.jks`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Generate the base64 value with:

```bash
base64 -w 0 mobile/android/upload-keystore.jks
```

### 3. Publish a shareable APK link

Run the workflow at `.github/workflows/android-apk-release.yml` from the GitHub Actions tab. It will:

- build a signed release APK
- upload it as a workflow artifact
- create a GitHub Release with the APK attached

The release URL will look like:

```text
https://github.com/AnarTHEmegamind0/golomt-cargo/releases/tag/android-v1.0.0-b1
```

That release page is the easiest link to send to testers.

## App Flow

- Starts on **Login**
- **Sign in** navigates to a bottom-tab shell: **Home**, **Profile**, **Settings**
- **Profile** loads demo profile data
- **Settings** toggles theme mode and allows **Logout**

## Project Structure

- `lib/core/`: app theme, DI (`AppProviders`), global navigation keys
- `lib/features/<feature>/`: `models/`, `repositories/`, `services/`, `providers/`, `pages/`, `widgets/`

## Notes

- `FakeAuthRepository`, `FakeProfileRepository`, and `InMemorySettingsRepository` are placeholders; swap in real implementations for production.
- Settings are in-memory only (reset on restart) until a persistent `SettingsRepository` is implemented.
