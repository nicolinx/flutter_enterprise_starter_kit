# flutter-enterprise-starter-kit

[![CI](https://github.com/nicolinx/flutter_enterprise_starter_kit/actions/workflows/ci.yml/badge.svg)](https://github.com/nicolinx/flutter_enterprise_starter_kit/actions/workflows/ci.yml)

A Flutter starter kit built the way a production app would be set up: Clean Architecture, Cubit
state management, dependency injection, Firebase, and multi-flavor builds, not just a tutorial
demo. Built as a public reference project.

## Features

- [x] Clean Architecture (`data` / `domain` / `presentation`) per feature
- [x] Cubit state management (`flutter_bloc`)
- [x] Dependency injection (`get_it`)
- [x] Firebase Authentication: email/password sign-in, register, sign-out
- [x] Dev/prod flavors, each with its own Firebase project
- [x] Typed error handling (`Freezed` + `Either`, via `fpdart`)
- [x] Unit & Cubit tests (`mocktail`, `bloc_test`)
- [x] GitHub Actions CI: analyze + test on every PR
- [x] REST API feature via `Dio`, with local caching (`posts`)
- [x] Fastlane: build + Firebase App Distribution per flavor (Android); iOS build validation only

## Tech stack

Flutter, Dart, flutter_bloc, get_it, Dio, Freezed, json_serializable, Firebase Auth, go_router,
fpdart, hive_ce, very_good_analysis, GitHub Actions, Fastlane

## Project structure

```
lib/
  core/           # DI, networking, error handling, theming, routing; shared by every feature
  features/
    auth/         # Firebase email/password auth, the fullest example, read this one first
    home/         # Post-login landing page
    posts/        # REST CRUD via Dio, real Freezed+json_serializable model, Hive cache
  app.dart, bootstrap.dart, main_development.dart, main_production.dart
```

Every feature follows the same `data -> domain -> presentation` layering. See
**[ARCHITECTURE.md](ARCHITECTURE.md)** for why each piece exists, a full request walkthrough, and
the platform-specific gotchas (Firebase's duplicate-app conflict, macOS entitlements) hit and
fixed along the way.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.freezed.dart / *.g.dart
flutter run -t lib/main_development.dart                   # or lib/main_production.dart
```

The checked-in `firebase_options_*.dart` files point at this repo's own Firebase projects. To run
against your own, create two Firebase projects with Email/Password Authentication enabled, then:

```bash
flutterfire configure --project=<your-dev-project> --out=lib/firebase_options_development.dart
flutterfire configure --project=<your-prod-project> --out=lib/firebase_options_production.dart
```

Run the test suite:

```bash
flutter test
```

## Fastlane

```bash
fastlane android build_dev        # or build_prod
fastlane android distribute_dev   # builds, then uploads to Firebase App Distribution
fastlane ios build_dev            # compiles only, no signing (see ARCHITECTURE.md)
```

`distribute_dev`/`distribute_prod` need a `FIREBASE_TOKEN` environment variable (`firebase login:ci`
generates one). The same lanes run from `.github/workflows/release.yml`, triggered manually from
the Actions tab with a flavor choice, using a `FIREBASE_TOKEN` repository secret.

## Roadmap

- [ ] Real Android release signing (current release builds use Flutter's default debug-signed
  config, fine for Firebase App Distribution, not for the Play Store)
- [ ] iOS distribution, blocked on a paid Apple Developer Program account (see ARCHITECTURE.md)
