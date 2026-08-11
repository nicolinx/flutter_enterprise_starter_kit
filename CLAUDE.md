# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Start here

Before writing or modifying any Dart code, read:

- **[RULES.md](RULES.md)** — strict coding standards (null safety, `const`, naming,
  widget extraction, package usage). Treat these as binding, not stylistic suggestions.
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — the single architecture reference: feature-first Clean
  Architecture, layer boundaries, state management, routing, DI, error handling, and *why* each
  decision was made, plus platform-specific gotchas (Firebase duplicate-app conflict, macOS
  entitlements) and CI/CD reasoning. Read this to know both *where* new code belongs and *why* the
  codebase is shaped this way before writing anything.

`auth` and `features/posts` are the canonical, fully-built features — mirror their shape for
anything new. `home` is intentionally a minimal placeholder.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate *.freezed.dart / *.g.dart after editing any @freezed/@JsonSerializable class
flutter run -t lib/main_development.dart                   # or lib/main_production.dart
flutter test                                                # full suite
flutter test test/path/to/some_test.dart                    # single file
flutter analyze                                              # lint (very_good_analysis, see analysis_options.yaml)
dart format .                                                 # format
```

Run `build_runner` after touching any file with `@freezed`, `@JsonSerializable`, or their
`part` directives — generated `*.freezed.dart`/`*.g.dart` files are checked in and must stay in
sync; never hand-edit them.

## Non-negotiables

- Follow `RULES.md` exactly: no `var`/`dynamic`, `final`-first, `const` everywhere possible,
  no `!` bang operator, no bare `try`/`catch` in cubits or use cases (only repositories catch
  exceptions and convert to `Either<Failure, T>`).
- Respect the dependency direction: `presentation` -> `domain` <- `data`. `domain` never imports
  Flutter/Firebase/Dio. A cubit depends on use cases only, never on a repository or data source.
- Don't add a `staging` flavor, switch off `Either`/`fpdart`, introduce `Bloc` events, or swap in
  `injectable`-style DI codegen — these were deliberately rejected; see `ARCHITECTURE.md` before
  reopening any of them.
