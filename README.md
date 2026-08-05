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
- [ ] REST API feature via `Dio` (in progress)
- [ ] Fastlane
- [ ] GitHub Actions CI

## Tech stack

Flutter, Dart, flutter_bloc, get_it, Dio, Freezed, Firebase Auth, go_router, fpdart,
very_good_analysis

## Project structure

```
lib/
  core/           # DI, networking, error handling, theming, routing; shared by every feature
  features/
    auth/         # Firebase email/password auth, the fullest example, read this one first
    home/         # Post-login landing page
    posts/        # REST/Dio feature (scaffolded, in progress)
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

## Roadmap

- [ ] `posts`: REST CRUD via Dio, with a "real" Freezed data model (unlike `auth`)
- [ ] Fastlane: automated builds/deploys per flavor
- [ ] GitHub Actions: analyze + test on every PR
