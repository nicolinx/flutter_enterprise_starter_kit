# flutter-enterprise-starter-kit

An opinionated Flutter starter kit demonstrating Clean Architecture, Cubit-based state
management, dependency injection, networking, code generation, Firebase integration, flavors,
and CI/CD tooling the way a production app would use them — built as a reference/portfolio
project.

> **Status**: foundation layer only (see [Roadmap](#roadmap)). No feature UI yet — this establishes
> the architecture everything else builds on.

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

## Project structure

```
lib/
  core/                # Cross-feature infrastructure — nothing here knows about a specific feature
    config/             # FlavorConfig: dev/prod environment, API base URL, app name
    di/                 # get_it registration (configureDependencies())
    error/               # Exception types (data layer) + Failure sealed class (domain/presentation)
    network/            # Dio client factory + interceptors (logging, error normalization)
    router/             # go_router configuration
    theme/               # AppTheme / AppColors / AppTextStyles design tokens
    usecase/             # UseCase<ResultType, Params> base class + NoParams
    presentation/        # Shared widgets/pages not owned by a specific feature
  features/
    auth/                # Firebase Auth feature (scaffolded, not yet implemented)
    posts/               # REST/Dio CRUD feature (scaffolded, not yet implemented)
      data/
        datasources/      # Remote/local data sources — throw typed exceptions
        models/            # Freezed + json_serializable DTOs, map to/from domain entities
        repositories/      # Implement domain repository interfaces, catch exceptions -> Failure
      domain/
        entities/          # Plain domain objects, no serialization/Flutter knowledge
        repositories/       # Abstract interfaces the data layer implements
        usecases/           # One class per business action, extends UseCase
      presentation/
        cubit/              # State management for this feature
        pages/               # Screens
        widgets/             # Feature-local widgets
  app.dart               # MaterialApp.router + theme + router wiring
  bootstrap.dart          # Shared init: DI, error zone, runApp — identical across flavors
  main_development.dart   # Sets FlavorConfig for dev, then calls bootstrap()
  main_production.dart    # Sets FlavorConfig for prod, then calls bootstrap()
test/
  core/                  # Mirrors lib/core — unit tests for failures, use cases, widget tests
  features/               # Will mirror lib/features as features land
```

Each feature under `lib/features/` follows the same `data/domain/presentation` shape, so once
you've read one feature you can navigate any other.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.freezed.dart / *.g.dart
flutter run -t lib/main_development.dart                   # or lib/main_production.dart
```

Run the test suite:

```bash
flutter test
```

## Roadmap

This repo is being built incrementally in public. Current state: foundation layer (DI, error
handling, networking, theming, routing, flavors) with a placeholder landing screen proving it's
all wired together correctly.

Next up:
- `flutterfire configure` against two Firebase projects (`-dev` / `-prod`) with Email/Password
  Authentication enabled
- `auth` feature: Firebase Auth end-to-end (data source → repository → use cases → cubit → UI)
- `posts` feature: REST CRUD via Dio against a public API, showing the same architecture with a
  different data source
- Fastlane for automated builds/deploys per flavor
- GitHub Actions CI: analyze + test on every PR, flavor-specific builds on release
