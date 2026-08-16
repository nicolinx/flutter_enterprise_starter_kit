# Flutter Enterprise Starter Kit

[![CI](https://img.shields.io/github/actions/workflow/status/nicolinx/flutter_enterprise_starter_kit/ci.yml?style=flat)](https://github.com/nicolinx/flutter_enterprise_starter_kit/actions/workflows/ci.yml)
[![Stars](https://img.shields.io/github/stars/nicolinx/flutter_enterprise_starter_kit?style=flat)](https://github.com/nicolinx/flutter_enterprise_starter_kit/stargazers)
[![Forks](https://img.shields.io/github/forks/nicolinx/flutter_enterprise_starter_kit?style=flat)](https://github.com/nicolinx/flutter_enterprise_starter_kit/network/members)

An open source Flutter starter kit showing how a production app is actually built: Clean Architecture, Cubit state management, dependency injection, Firebase, and a complete CI/CD pipeline, ready to build on.

## Features

- [x] Clean Architecture (`data` / `domain` / `presentation`) per feature
- [x] Cubit state management (`flutter_bloc`)
- [x] Dependency injection (`get_it`)
- [x] Firebase Authentication: email/password sign-in, register, sign-out
- [x] Dev/prod flavors, each with its own Firebase project — [bring your own project](docs/FIREBASE_SETUP.md)
- [x] Typed error handling (`Freezed` + `Either`, via `fpdart`)
- [x] Unit & Cubit tests (`mocktail`, `bloc_test`)
- [x] GitHub Actions CI: analyze + test on every PR
- [x] REST API feature via `Dio`, with local caching (`posts`)
- [x] Fastlane: build + Firebase App Distribution per flavor (Android); iOS build validation only
- [x] Agentic coding-ready: `CLAUDE.md` / `RULES.md` / `ARCHITECTURE.md` give AI coding agents
      (Claude Code, Cursor, etc.) enough context to generate code that matches this repo's
      conventions instead of guessing at them
- [x] Feature flags via Firebase Remote Config, with a local dev override (`core/feature_flags/`)

## Tech stack

| Layer                     | Tools                          |
| ------------------------- | ------------------------------ |
| Language & framework      | Flutter, Dart                  |
| State management          | `flutter_bloc` (Cubit)         |
| Dependency injection      | `get_it`                       |
| Networking                | `dio`                          |
| Code generation           | `freezed`, `json_serializable` |
| Backend                   | Firebase Auth                  |
| Routing                   | `go_router`                    |
| Functional error handling | `fpdart`                       |
| Local storage             | `hive_ce`                      |
| Linting                   | `very_good_analysis`           |
| CI/CD                     | GitHub Actions, Fastlane       |

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
**[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** for why each piece exists, a full request walkthrough, and
the platform-specific gotchas (Firebase's duplicate-app conflict, macOS entitlements) hit and
fixed along the way. See **[docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)** to connect your own Firebase
projects instead of this repo's demo ones.

## Agentic coding support

This repo ships with context files so AI coding agents (Claude Code, Cursor, etc.) can generate
code that matches its existing conventions instead of inferring them from scratch each time:

- **[CLAUDE.md](CLAUDE.md)** — entry point read automatically by Claude Code; points an agent at
  the other two files and lists the commands it needs (build_runner, test, analyze, format).
- **[docs/RULES.md](docs/RULES.md)** — strict, binding coding standards: null safety, `const` usage,
  naming, widget extraction, package usage.
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** — where code belongs (layer boundaries, state
  management, routing, DI, error handling) and why each decision was made.

Tools that don't read `CLAUDE.md` natively can usually be pointed at it directly (e.g. as a
`.cursorrules`/custom-instructions source) since it's plain Markdown with no Claude-specific syntax.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.freezed.dart / *.g.dart
flutter run -t lib/main_development.dart                   # or lib/main_production.dart
```

The checked-in `firebase_options_*.dart` files point at this repo's own Firebase projects. To
connect your own, follow **[docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)**.

Run the test suite:

```bash
flutter test
```

## Fastlane

```bash
fastlane android build_dev        # or build_prod
fastlane android distribute_dev   # builds, then uploads to Firebase App Distribution
fastlane ios build_dev            # compiles only, no signing (see docs/ARCHITECTURE.md)
```

`distribute_dev`/`distribute_prod` need a `FIREBASE_TOKEN` environment variable (`firebase login:ci`
generates one). The same lanes run from `.github/workflows/release.yml`, using a `FIREBASE_TOKEN`
repository secret, two ways:

- **dev**: automatically, on every push to `main`. No one has to remember to ship a dev build,
  it's always current.
- **prod**: manually, from the Actions tab (`workflow_dispatch`, flavor choice). Production stays
  a deliberate human action on purpose, see "Why Firebase App Distribution" in docs/ARCHITECTURE.md.

## Roadmap

- [ ] Reusable base components for one-off Cubit effects (SnackBars, navigation, dialogs)
- [ ] Real Android release signing (current release builds use Flutter's default debug-signed
      config, fine for Firebase App Distribution, not for the Play Store)
- [ ] iOS distribution, blocked on a paid Apple Developer Program account (see docs/ARCHITECTURE.md)
- [ ] Widget tests + coverage reporting (currently only unit/cubit tests exist; wire
      `flutter test --coverage` into CI with a coverage badge)
- [ ] Localization (`flutter_localizations`/`intl`), all user-facing strings are hardcoded today
- [ ] Push notifications via Firebase Cloud Messaging
- [ ] Analytics via Firebase Analytics
- [ ] Changelog automation from conventional commits (already used throughout this repo's history)
- [ ] Deep-link handling
- [ ] Network API retry mechanism

## Author

**Nicodemus Lin** — Software Engineer

[![Website](https://img.shields.io/badge/Website-nicolin.dev-4F46E5?style=for-the-badge&logo=globe&logoColor=white)](https://www.nicolin.dev/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Nicodemus_Lin-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/nicodemus-lin/)
