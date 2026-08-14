# Firebase Setup Guide

Connect your **own** Firebase projects to this starter kit, for both the `development` and
`production` flavors, instead of the demo projects checked in by default.

## Prerequisites

- A Google account.
- Firebase CLI:
  ```bash
  npm install -g firebase-tools
  firebase login
  ```
- FlutterFire CLI:
  ```bash
  dart pub global activate flutterfire_cli
  ```

## Step 1 — Create two Firebase projects

In the [Firebase console](https://console.firebase.google.com/), create **two** projects — one
for `development`, one for `production` (mirroring this repo's two flavors). For example, if
your app is called `myapp`, name them `myapp-dev` and `myapp-prod`.

## Step 2 — Enable Email/Password sign-in

In **both** projects: Authentication → Sign-in method → enable **Email/Password**. The `auth`
feature needs this to sign up/sign in at all.

## Step 3 — Run FlutterFire configure for each flavor

```bash
flutterfire configure --project=<your-dev-project-id> --out=lib/firebase_options_development.dart
flutterfire configure --project=<your-prod-project-id> --out=lib/firebase_options_production.dart
```

For example, with the project names from Step 1:

```bash
flutterfire configure --project=myapp-dev --out=lib/firebase_options_development.dart
flutterfire configure --project=myapp-prod --out=lib/firebase_options_production.dart
```

Each run is interactive and asks which platforms to configure. This overwrites
`lib/firebase_options_*.dart`, `firebase.json`, and `android/app/google-services.json`.

## Step 4 — Delete regenerated iOS/macOS plist files

This repo intentionally doesn't ship `GoogleService-Info.plist` — Firebase is initialized
explicitly per flavor in `bootstrap.dart`, and a native config file auto-initializing Firebase
too causes a `[core/duplicate-app]` crash. If you selected iOS/macOS above, delete what
`flutterfire configure` wrote back:

```bash
rm -f ios/Runner/GoogleService-Info.plist macos/Runner/GoogleService-Info.plist
```

`android/app/google-services.json` is fine to keep — Android's auto-init is already disabled
in `AndroidManifest.xml`, so the file just needs to be present for Gradle, not correct.

## Step 5 — (Optional) Remote Config for feature flags

Add a boolean parameter `home_banner` in each project's Remote Config console if you want to
control the demo banner remotely. Skip this and it falls back to a local dev toggle.

## Step 6 — Run it

```bash
flutter run -t lib/main_development.dart   # or lib/main_production.dart
```

Sign up a test user and confirm it shows up under Authentication → Users in your **dev**
project's console.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `[core/duplicate-app] Firebase App named "[DEFAULT]" already exists` | Re-check [Step 4](#step-4--delete-regenerated-iosmacos-plist-files). |
| macOS `network-request-failed` / `keychain-error` | Missing entitlements or no code-signing Team in Xcode — see ARCHITECTURE.md. |
| Android build fails looking for `google-services.json` | Rerun `flutterfire configure` with Android selected. |

See [ARCHITECTURE.md](ARCHITECTURE.md) ("Firebase config is selected in Dart, not native
files") for the full rationale behind these steps.
