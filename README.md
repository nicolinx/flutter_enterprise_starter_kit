# flutter-enterprise-starter-kit

An opinionated Flutter starter kit demonstrating Clean Architecture, Cubit-based state
management, dependency injection, networking, code generation, Firebase integration, flavors,
and CI/CD tooling the way a production app would use them — built as a reference/portfolio
project.

> **Status**: foundation layer + `auth` feature (Firebase Auth, email/password) done. See
> [Roadmap](#roadmap) for what's next.

## Why these choices

- **Clean Architecture (data / domain / presentation)** — each feature is isolated into layers so
  business logic never depends on Flutter, Dio, or Firebase directly. This is what actually makes
  a codebase testable and lets a data source change (REST → GraphQL, Firestore → Supabase) without
  touching domain or UI code.
- **Cubit over full Bloc** — this kit only uses `flutter_bloc`'s `Cubit`, not the event-based
  `Bloc` API. Every feature here is a direct action → state transition; `Bloc`'s event stream adds
  ceremony (event classes, `on<Event>` mapping) without buying anything until you need real event
  transformation (debounce/throttle/concurrency policies). Built on the same package, so the
  underlying mental model — unidirectional state, `BlocBuilder`/`BlocListener` — is identical.
- **`get_it` with manual registration, no `injectable`** — the original plan used `injectable`
  for annotation-based DI codegen. On this project's SDK (Dart 3.12.2, a very recent release),
  `injectable_generator`'s current version requires an `analyzer` version that stable `freezed`
  3.x doesn't yet support — the only way to keep both was pinning `freezed` to a prerelease
  (`4.0.0-dev`). Rather than anchor a portfolio project on a prerelease dependency, DI is
  registered explicitly in `lib/core/di/injection.dart`. It's a few more lines per dependency, no
  code generation step, and arguably easier to read in an interview than generated
  `injection.config.dart` output.
- **`fpdart`'s `Either<Failure, T>`** — repositories never throw across the domain boundary.
  Data sources throw typed exceptions (`ServerException`, `CacheException`, `NetworkException`);
  repositories catch those and return `Either<Failure, T>`, so every use case's success/failure
  path is explicit in its return type instead of hidden in a try/catch the caller has to
  remember to write.
- **Freezed for `Failure`** — a sealed class with one variant per failure kind
  (`ServerFailure`, `NetworkFailure`, `CacheFailure`, `UnexpectedFailure`), each carrying a
  message. Exhaustive `switch`/`map` on `Failure` means the analyzer catches a missing case at
  compile time instead of a silent fallthrough at runtime.
- **`very_good_analysis` over `flutter_lints`** — a stricter, more opinionated lint set. Two rules
  are deliberately turned off (see `analysis_options.yaml`): `public_member_api_docs` (would
  require dartdoc on every public member — too strict for a project meant to stay readable, not
  bureaucratic) and `one_member_abstracts` (flags single-method abstract classes, which is
  exactly the shape of `UseCase<ResultType, Params>` and every repository interface in a Clean
  Architecture codebase — the lint's assumption doesn't hold here).
- **Two flavors, not three** — `development` and `production` only. A `staging` flavor would
  follow the identical pattern (a `main_staging.dart` + a third Firebase project), but a
  three-environment setup is real ongoing upkeep (security rules, quota, cleanup) for a project
  whose primary audience is people reading the code, not a QA team.
- **Firebase config selected in Dart, not native files** — two Firebase projects
  (`flutter-enterprise-kit-dev`/`-prod`) were set up via `flutterfire configure`, once per flavor,
  each with `--out=lib/firebase_options_<flavor>.dart`. `bootstrap.dart` picks the right
  `DefaultFirebaseOptions.currentPlatform` based on `FlavorConfig.instance.flavor` and passes it
  explicitly to `Firebase.initializeApp(options: ...)`. This is what makes two-Firebase-project
  flavors possible without native Android/iOS product-flavor build variants (see the `get_it`
  choice above — same "keep the Dart layer as the single source of truth" instinct).

  One consequence worth knowing about: Firebase's native plugins auto-configure a default app
  from whatever config file is bundled (`GoogleService-Info.plist` on iOS/macOS,
  `google-services.json`'s injected resources via a `FirebaseInitProvider` `ContentProvider` on
  Android) *before* any Dart code runs. Left in place, that races our explicit
  `Firebase.initializeApp()` call and throws `[core/duplicate-app] A Firebase App named
  "[DEFAULT]" already exists`. Fixed by removing `GoogleService-Info.plist` from the iOS/macOS
  Xcode projects entirely (`flutterfire configure` writes them, but since we pass
  `FirebaseOptions` explicitly they're redundant) and disabling `FirebaseInitProvider` in
  `android/app/src/main/AndroidManifest.xml` via `tools:node="remove"`. `google-services.json`
  and the Google Services Gradle plugin are left in place — harmless once the auto-init
  `ContentProvider` is disabled, and some Firebase tooling still expects them present.
- **macOS network client entitlement** — `flutter create`'s default macOS entitlements
  (`macos/Runner/{DebugProfile,Release}.entitlements`) enable App Sandbox with
  `com.apple.security.network.server` (needed for the debug/VM-service connection) but *not*
  `com.apple.security.network.client`. Without it, every outbound network call — Firebase Auth,
  and later Dio for the `posts` feature — fails with a sandboxed
  `network-request-failed`/connection-refused error that has nothing to do with the request
  itself. Added `network.client: true` to both entitlements files; this is a one-time fix that
  covers every feature that talks to the network on macOS, not just auth.

## Project structure

```
lib/
  core/                  # Cross-feature infrastructure — nothing here knows about a specific feature
    config/               # FlavorConfig: dev/prod environment, API base URL, app name
    di/                   # get_it registration (configureDependencies())
    error/                 # Exception types (data layer) + Failure sealed class (domain/presentation)
    network/              # Dio client factory + interceptors (logging, error normalization)
    router/               # go_router config + redirect-on-auth-state (GoRouterRefreshStream)
    theme/                 # AppTheme / AppColors / AppTextStyles design tokens
    usecase/               # UseCase<ResultType, Params> base class + NoParams
  features/
    auth/                  # Firebase Auth: email/password sign-in, register, sign-out
      data/
        datasources/        # AuthRemoteDataSource — wraps FirebaseAuth, throws typed exceptions
        models/              # firebase_auth.User -> domain User mapper (no JSON here, see below)
        repositories/        # AuthRepositoryImpl — exceptions -> Failure
      domain/
        entities/            # User
        repositories/         # AuthRepository interface
        usecases/             # SignInWithEmailAndPassword, RegisterWithEmailAndPassword, SignOut
      presentation/
        cubit/                # AuthCubit (global sign-in state), LoginCubit, RegisterCubit
        pages/                 # LoginPage, RegisterPage
        widgets/               # AuthTextField
      auth_injection.dart     # configureAuthDependencies(), called from core/di/injection.dart
    home/                   # Post-login landing page (will grow once `posts` lands)
      presentation/pages/     # HomePage
    posts/                  # REST/Dio CRUD feature (scaffolded, not yet implemented)
      data/{datasources,models,repositories}/
      domain/{entities,repositories,usecases}/
      presentation/{cubit,pages,widgets}/
  app.dart                 # MaterialApp.router + theme + router wiring, provides AuthCubit
  bootstrap.dart            # Shared init: Firebase, DI, error zone, runApp — same across flavors
  main_development.dart     # Sets FlavorConfig for dev, then calls bootstrap()
  main_production.dart      # Sets FlavorConfig for prod, then calls bootstrap()
  firebase_options_development.dart  # Generated by `flutterfire configure`, dev project
  firebase_options_production.dart   # Generated by `flutterfire configure`, prod project
test/
  core/                    # Mirrors lib/core — unit tests for failures, use cases
  features/auth/             # Repository test (mocktail) + Cubit tests (bloc_test)
```

Each feature under `lib/features/` follows the same `data/domain/presentation` shape, so once
you've read one feature you can navigate any other. `auth` is the fullest example — read it first.

The `auth` feature also shows a deliberate deviation: `data/models/` has no Freezed/
`json_serializable` model. The Firebase SDK already returns a typed `User` object, not raw JSON,
so there's nothing to deserialize — just a plain mapping extension to the domain entity. The
`posts` feature (REST-backed) will show the more typical Freezed-model shape for comparison.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.freezed.dart / *.g.dart
flutter run -t lib/main_development.dart                   # or lib/main_production.dart
```

`firebase_options_development.dart`/`firebase_options_production.dart` are checked in and point
at this repo's own Firebase projects — to run against your own, create two Firebase projects
with Email/Password Authentication enabled, then regenerate both files:

```bash
flutterfire configure --project=<your-dev-project> --out=lib/firebase_options_development.dart
flutterfire configure --project=<your-prod-project> --out=lib/firebase_options_production.dart
```

Run the test suite:

```bash
flutter test
```

## Roadmap

This repo is being built incrementally in public. Current state: foundation layer (DI, error
handling, networking, theming, routing, flavors) plus a working `auth` feature — register, sign
in, sign out, with the router redirecting based on live auth state.

Next up:
- `posts` feature: REST CRUD via Dio against a public API, showing the same architecture with a
  different data source (and a "real" Freezed data model, unlike `auth`)
- Fastlane for automated builds/deploys per flavor
- GitHub Actions CI: analyze + test on every PR, flavor-specific builds on release
