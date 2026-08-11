# Coding Rules

Strict, machine-checkable conventions for this codebase. These are extracted from the existing
source and enforced by `analysis_options.yaml` (`very_good_analysis`, with `public_member_api_docs`
and `one_member_abstracts` explicitly disabled — see that file for why). Follow them without
exception. If a new requirement seems to conflict with a rule here, flag it instead of silently
breaking the rule.

For the architecture these rules assume — layer boundaries, state management, routing, DI, error
handling, and the reasoning behind each — see [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Language & type safety

- **Never use `var` or `dynamic`.** Declare an explicit type, or let strong inference apply to a
  `final` with an unambiguous right-hand side (e.g. `final posts = await _remoteDataSource.getPosts();`
  is fine because the return type is obvious from the call).
- **Always prefer `final` over mutable locals.** Only use a non-final local when the variable is
  genuinely reassigned. Class fields that are set once (via constructor) are also `final`.
- **Null safety is not optional.** Model absence with `?` and handle it explicitly (`??`, `?.`, or
  a null check) — never use the `!` bang operator to silence the analyzer. If you find yourself
  reaching for `!`, the type should probably not be nullable in the first place, or you're missing
  a guard.
- Constructor parameters that are required and non-nullable use `required` with no default; make a
  field nullable (`Type?`) only when absence is a real, meaningful state — not as a shortcut to
  avoid providing a default.
- Use `const` constructors for every value object (`Failure`, `User`, `NoParams`, exceptions).
  Exceptions and simple value classes take a `const` constructor with a default argument
  (`const ServerException([this.message = 'A server error occurred'])`) rather than a factory or
  named parameter with a default.

## `const` correctness

- **Every widget, literal, or constructor call that can be `const`, must be `const`.** This
  includes `SizedBox`, `Icon`, `Text('literal')`, `EdgeInsets.all(...)`, empty state widgets, and
  entire subtrees when every child is itself const-constructible.
- Every `StatelessWidget`/`StatelessWidget`-like class must have a `const` constructor
  (`const MyWidget({super.key})`), including private `_`-prefixed widgets.
- When a widget has no parameters beyond `key`, its call site should use `const` explicitly (e.g.
  `const Center(child: CircularProgressIndicator())`) — don't rely on the analyzer to catch a
  missing `const` for you; write it correctly the first time.

## Naming conventions

- **Classes/types**: `UpperCamelCase`. Cubits are named `<Feature>Cubit` (`LoginCubit`,
  `PostFormCubit`); their states are `<Feature>State` and are `sealed` Freezed unions with one
  factory per state (`LoginState.initial()`, `LoginState.submitting()`, `LoginState.success()`,
  `LoginState.failure(String message)`).
- **Use cases**: named as a verb phrase matching the action, in `UpperCamelCase`, one class per
  file (`GetPosts`, `SignInWithEmailAndPassword`, `DeletePost`). Their `Params` class is named
  `<UseCase>Params` (`CreatePostParams`, `SignInWithEmailAndPasswordParams`) and lives in the same
  file as the use case.
- **Files**: `snake_case.dart` matching the primary class inside (`login_cubit.dart` ->
  `LoginCubit`, `post_repository_impl.dart` -> `PostRepositoryImpl`).
- **Private widgets/members**: prefix with `_` (`_PostsListView`, `_demoUserId`, `_messageFor`).
  Split a page into a public `StatelessWidget` (wires up `BlocProvider`/DI only) plus a private
  `_...View` widget that does the actual `build` — see "Widget extraction" below.
- **Booleans**: read as a predicate (`isConnected`, `isAuthenticated`, `isAuthRoute`,
  `obscureText`). Never prefix with `get` or suffix with `Flag`.
- **Interfaces vs implementations**: the abstract contract has the plain name (`AuthRepository`,
  `PostRepository`, `NetworkInfo`); the concrete class is the same name + `Impl`
  (`AuthRepositoryImpl`, `PostRepositoryImpl`, `NetworkInfoImpl`).

## Widget extraction & UI structure

- **UI files are dumb.** A `Page` widget's only job is to obtain a cubit from `getIt` and wrap the
  real view in a `BlocProvider`. It does not contain business logic, does not call repositories or
  use cases directly, and does not branch on state itself.
- Extract the actual visual tree into a private `_<Name>View` `StatelessWidget` (or
  `StatefulWidget` only if local, UI-only state like a `TextEditingController` is required). Pages
  never inline a large `build` method with cubit-wiring and layout mixed together.
- Read/react to state with `BlocBuilder`/`BlocListener`/`context.read<Cubit>()`. Prefer exhaustive
  `switch` (Dart 3 pattern matching, e.g. `switch (state) { PostsLoaded(:final posts) => ... }`)
  over `if`/`else` chains or `state is X` checks when branching on a sealed Freezed state — the
  analyzer then guarantees every state variant is handled.
- Feature-local, reusable widgets (e.g. `AuthTextField`) live in `presentation/widgets/` and take
  every piece of data/behavior via constructor parameters (`controller`, `label`, `validator`).
  They hold no cubit reference and know nothing about which feature/screen uses them.
- Trigger side effects (`unawaited(cubit.load())`) inside `BlocProvider.create`, not in
  `initState`/`build`, to keep the widget itself stateless where possible.

## State management (Cubit)

- One `Cubit` per screen/feature slice. It depends only on domain-layer use cases (never on a
  repository or data source directly, and never on Flutter widgets).
- Cubit methods are named after the user action, not the mechanism (`submit`, `load`, `delete`),
  and always emit a "working" state before the async call, then pattern-match the `Either` result
  with `.match((failure) => ..., (success) => ...)` from `fpdart` to emit the terminal state. Never
  `try`/`catch` inside a cubit — the repository has already converted exceptions to `Either`.
- States are immutable, `@freezed sealed class`es with one factory constructor per variant, no
  business logic inside the state class itself.

## Error handling

- **Data sources throw; everything above the data layer receives `Either`.** A `DataSource` throws
  one of the typed exceptions from `core/error/exceptions.dart` (`ServerException`,
  `CacheException`, `NetworkException`) — never a bare `Exception`, never an untyped `throw`.
- **Repositories catch exceptions and return `Either<Failure, T>`** (`fpdart`), using `Left`/`Right`
  or a private `_guard` helper that wraps the common try/catch. A repository method never lets an
  exception propagate to its caller.
- **Use cases and cubits never use `try`/`catch`.** They call a repository (via a use case) and
  handle the `Either` with `.match(...)`, `.fold(...)`, or pattern matching — the failure path is
  a type, not a caught exception.
- Never use a generic top-level `catch (e)`. Catch the specific typed exception you expect from
  that call site.

## Package usage

- **State management**: `flutter_bloc`'s `Cubit` only. Do not introduce `Bloc`/events unless the
  feature genuinely needs event transformation (debounce/throttle/concurrency) — see
  `architecture.md`.
- **Functional error handling**: `fpdart`'s `Either<Failure, T>` and `Unit`/`unit` for void
  successes. Do not throw across a repository boundary; do not introduce another Result/Either
  type.
- **Routing**: `go_router` only, configured in one place (`core/router/app_router.dart`). Screens
  never construct `MaterialPageRoute` or call `Navigator.push` directly for feature navigation —
  use `context.push(RoutePaths....)`/`context.go(...)`.
- **DI**: `get_it`, manually registered (no `injectable`, no code-generated DI container). Every
  feature exposes a `configure<Feature>Dependencies()` top-level function in a
  `<feature>_injection.dart` file at the feature root, called from `core/di/injection.dart`.
- **Models/DTOs**: `freezed` + `json_serializable` for anything that round-trips through JSON
  (`PostModel`). If a data source already returns a typed SDK object (e.g. Firebase's `User`), use
  a plain extension mapper (`toDomain()`) instead of introducing a redundant Freezed model — do
  not add `freezed`/JSON codegen where there is no JSON.
  Once a feature commits to one of these two shapes, stay consistent within that feature.
- **Networking**: `dio`, constructed once via `createDioClient()` and registered as a singleton in
  `get_it`. Add cross-cutting HTTP behavior as an interceptor in `core/network/interceptors/`, not
  inline in a data source.
- **Local cache**: `hive_ce`, storing plain `Map`/`List`/primitives (via a model's `toJson()`), not
  hand-rolled `TypeAdapter`s, unless the data can't be represented as JSON-safe primitives.
- **Connectivity**: `connectivity_plus`, wrapped by `NetworkInfo`/`NetworkInfoImpl` — check
  `networkInfo.isConnected` in a repository, never call `connectivity_plus` directly outside that
  wrapper.

## Imports & structure

- Always use full `package:flutter_enterprise_starter_kit/...` imports for cross-directory
  project code (not relative `../../` imports).
- One public class per file, file named after it in `snake_case`.
- `part`/`part of` only for generated Freezed/`json_serializable` output (`*.freezed.dart`,
  `*.g.dart`). Never hand-edit a generated file — change the annotated source and rerun
  `build_runner`.

## Comments & documentation

- No comments that restate what the code does. A comment is only warranted for a non-obvious
  *why* (a workaround, a deliberate deviation between features, a gotcha) — see the header
  comments in `post_model.dart`, `user_mapper.dart`, and `injection.dart` for the expected style
  and density.
- `public_member_api_docs` is disabled project-wide: do not add dartdoc to every public member out
  of habit. Names should be self-explanatory; reserve doc comments for genuinely non-obvious
  contracts (see `core/usecase/usecase.dart`, `core/error/failures.dart`).

## Formatting

- Format with `dart format` defaults (trailing commas drive multi-line argument wrapping — keep
  a trailing comma on the last positional/named argument of any call you expect to stay
  multi-line).
- Cascades (`..registerLazySingleton(...)`) over repeated `getIt.register...` statements when
  configuring multiple dependencies on the same target in sequence.
- No `print()` anywhere in `lib/`. If you need runtime diagnostics, add a proper logging
  interceptor/service instead (see `core/network/interceptors/logging_interceptor.dart` for the
  existing pattern with `pretty_dio_logger`).

## Git commit messages

- Keep commit messages short: a single summary line. Only add a body when the *why* genuinely
  isn't obvious from the diff or the summary line itself.
- Do not add a `Co-Authored-By` trailer (or any other AI-attribution trailer/footer) to commits in
  this repository.
