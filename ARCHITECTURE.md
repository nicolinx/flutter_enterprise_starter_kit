# Architecture

This document explains the reasoning behind the non-obvious decisions in this codebase, and the
platform-specific issues hit (and fixed) along the way. The [README](README.md) covers the quick
tour: start there if you just want to run the app.

## Why Clean Architecture

Each feature is split into `data` / `domain` / `presentation`, and dependencies only point
inward: `presentation` depends on `domain`, `data` implements `domain`'s interfaces, and `domain`
depends on nothing external (no Flutter, no Firebase, no Dio). This is what makes the codebase
testable and lets a data source change (REST to GraphQL, Firestore to Supabase) without touching
domain or UI code. See [`lib/features/auth`](lib/features/auth) for a full example, walked
through layer-by-layer below.

## Why Cubit, not full Bloc

This kit only uses `flutter_bloc`'s `Cubit`, not the event-based `Bloc` API. Every feature here
is a direct action-to-state transition; `Bloc`'s event stream adds ceremony (event classes,
`on<Event>` mapping) without buying anything until you need real event transformation
(debounce/throttle/concurrency policies). Built on the same package, so the underlying mental
model, unidirectional state with `BlocBuilder`/`BlocListener`, is identical.

## Why `get_it` with manual registration, no `injectable`

The original plan used `injectable` for annotation-based DI codegen. On this project's SDK (Dart
3.12.2, a very recent release), `injectable_generator`'s current version requires an `analyzer`
version that stable `freezed` 3.x doesn't yet support. The only way to keep both was pinning
`freezed` to a prerelease (`4.0.0-dev`). Rather than anchor this project on a prerelease
dependency, DI is registered explicitly in `lib/core/di/injection.dart`. A few more lines per
dependency, no code generation step, and arguably easier to read than generated
`injection.config.dart` output.

## Why `Either<Failure, T>` (fpdart) instead of exceptions

Repositories never throw across the domain boundary. Data sources throw typed exceptions
(`ServerException`, `CacheException`, `NetworkException`); repositories catch those and return
`Either<Failure, T>`, so every use case's success/failure path is explicit in its return type
instead of hidden in a try/catch the caller has to remember to write.

## Why Freezed for `Failure`

`Failure` is a sealed class with one variant per failure kind (`ServerFailure`, `NetworkFailure`,
`CacheFailure`, `UnexpectedFailure`), each carrying a message. Exhaustive `switch`/`map` on
`Failure` means the analyzer catches a missing case at compile time instead of a silent
fallthrough at runtime.

## Why `very_good_analysis` over `flutter_lints`

A stricter, more opinionated lint set. Two rules are deliberately turned off (see
`analysis_options.yaml`):
- `public_member_api_docs`: would require dartdoc on every public member, too strict for a
  project meant to stay readable, not bureaucratic.
- `one_member_abstracts`: flags single-method abstract classes, which is exactly the shape of
  `UseCase<ResultType, Params>` and every repository interface here. The lint's assumption
  doesn't hold in this codebase.

## Why two flavors, not three

`development` and `production` only. A `staging` flavor would follow the identical pattern (a
`main_staging.dart` plus a third Firebase project), but a three-environment setup is real ongoing
upkeep (security rules, quota, cleanup) for a project whose primary audience is people reading
the code, not a QA team.

## Firebase config is selected in Dart, not native files

Two Firebase projects (`flutter-enterprise-kit-dev`/`-prod`) were set up via `flutterfire
configure`, once per flavor, each with `--out=lib/firebase_options_<flavor>.dart`.
`bootstrap.dart` picks the right `DefaultFirebaseOptions.currentPlatform` based on
`FlavorConfig.instance.flavor` and passes it explicitly to `Firebase.initializeApp(options: ...)`.
Same "keep the Dart layer as the single source of truth" instinct as the `get_it` choice above,
and what makes two-Firebase-project flavors possible without native Android/iOS product-flavor
build variants.

### Gotcha: the duplicate-app conflict

Firebase's native plugins auto-configure a default app from whatever config file is bundled
(`GoogleService-Info.plist` on iOS/macOS, `google-services.json`'s injected resources via a
`FirebaseInitProvider` `ContentProvider` on Android) before any Dart code runs. Left in place,
that races the explicit `Firebase.initializeApp()` call and throws `[core/duplicate-app] A
Firebase App named "[DEFAULT]" already exists`.

Fixed by removing `GoogleService-Info.plist` from the iOS/macOS Xcode projects entirely
(`flutterfire configure` writes them, but since `FirebaseOptions` is passed explicitly they're
redundant) and disabling `FirebaseInitProvider` in `android/app/src/main/AndroidManifest.xml` via
`tools:node="remove"`. `google-services.json` and the Google Services Gradle plugin are left in
place, harmless once the auto-init `ContentProvider` is disabled, and some Firebase tooling still
expects them present.

### Gotcha: macOS network and keychain entitlements

`flutter create`'s default macOS entitlements enable App Sandbox with
`com.apple.security.network.server` (needed for the debug/VM-service connection) but not
`com.apple.security.network.client`. Without it, every outbound network call (Firebase Auth, and
later Dio for the `posts` feature) fails with a sandboxed `network-request-failed` that has
nothing to do with the request itself.

Firebase Auth on macOS also needs an explicit `keychain-access-groups` entitlement to persist
session tokens. Sandboxed macOS apps don't get this implicitly the way iOS apps do, and it
surfaces as a `keychain-error` with no useful detail. Both are fixed in
`macos/Runner/{DebugProfile,Release}.entitlements`, and also require a real code-signing Team
selected in Xcode (a free Apple ID personal team is enough, no paid developer account needed).

## Feature structure, in detail

Every feature under `lib/features/` follows the same shape:

```
feature/
  data/
    datasources/   # Talks to the actual SDK/API. Throws typed exceptions, never returns Either.
    models/        # Maps the raw SDK/API shape to domain entities (JSON model, or a mapper, see auth vs. posts)
    repositories/  # Implements the domain repository interface. Exceptions -> Either<Failure, T>.
  domain/
    entities/      # Plain value objects. No Flutter, no Firebase, no JSON.
    repositories/  # Abstract interfaces, the contract data/ implements.
    usecases/      # One class per business action. The only thing presentation/ is allowed to call.
  presentation/
    cubit/         # UI state for this feature.
    pages/         # Screens.
    widgets/       # Feature-local widgets.
```

`auth` and `posts` are worth reading side by side: same shape, different data source.
`auth`'s `data/models/` is a deliberate deviation: since Firebase's SDK already returns a typed
`User` object (not raw JSON), there's just a small mapping extension (`user_mapper.dart`) instead
of a full Freezed/`json_serializable` model. `posts` shows the more typical version: `PostModel`
is a real `@freezed` + `@JsonSerializable` DTO with generated `fromJson`/`toJson`, since its data
source (JSONPlaceholder over Dio) actually hands back JSON that needs parsing.

### Auth request walkthrough

Tapping "Sign in" on `LoginPage`:

1. `LoginCubit.submit()` emits `LoginState.submitting()`, then calls the
   `SignInWithEmailAndPassword` use case.
2. The use case forwards to `AuthRepository.signInWithEmailAndPassword()`. It only knows the
   abstract interface, not that `AuthRepositoryImpl` (Firebase-backed) is behind it.
3. `AuthRepositoryImpl` calls `AuthRemoteDataSource`, which calls `FirebaseAuth` directly. Any
   `FirebaseAuthException` is caught there and rethrown as a typed `ServerException`.
4. Back in `AuthRepositoryImpl`, that exception becomes `Left(Failure.server(message))`; success
   becomes `Right(user.toDomain())`.
5. `LoginCubit` pattern-matches the `Either` and emits `LoginState.failure(...)` or
   `LoginState.success()`.

Note what's not in this list: navigation. `LoginCubit` never calls `Navigator`/`GoRouter`
directly. Instead, `AuthRepositoryImpl.authStateChanges` wraps Firebase's own
`authStateChanges()` stream, `AuthCubit` (a single long-lived instance provided at the app root)
subscribes to it for the app's whole lifetime, and `go_router`'s `redirect` re-evaluates
automatically whenever `AuthCubit` emits (via `GoRouterRefreshStream`, which bridges the cubit's
stream to something `go_router` can listen to). A successful sign-in flips `AuthCubit` to
`authenticated`, and the router redirects away from `/login` on its own. The same mechanism
handles sign-out in reverse.

### `posts`: cache-aside reads, remote-only writes

`PostRepositoryImpl.getPosts()` is the one method in the codebase that branches on
`NetworkInfo.isConnected` (already built in `core/network/`, unused until this feature):
online, it fetches from `PostRemoteDataSource` (Dio against JSONPlaceholder), writes the result
into `PostLocalDataSource` (a Hive box, storing each post as its raw `toJson()` map, no generated
`TypeAdapter` needed since Hive stores `Map`/`List`/primitives natively), then returns it.
Offline, it skips the network entirely and reads whatever was last cached, returning
`Left(Failure.cache(...))` only if nothing has been cached yet. `createPost`/`updatePost`/
`deletePost` are remote-only, there's no offline write queue; that would be a meaningfully
different (and bigger) feature.

One Dio-specific detail worth calling out: `core/network/interceptors/error_interceptor.dart`
normalizes every `DioException` by calling `handler.next(err.copyWith(error: ourException))`, so
the typed exception arrives *inside* a rethrown `DioException.error`, not as a bare throw.
`PostRemoteDataSource` unwraps this (catch `DioException`, rethrow `e.error`) so the "data
sources only throw typed exceptions" rule still holds above it, exactly like `auth`'s data source
does for `FirebaseAuthException`.

Also worth knowing if you run the app: JSONPlaceholder is a fake API. `POST`/`PUT`/`DELETE`
requests return a plausible-looking success response, but nothing is actually persisted
server-side, refreshing the list after creating a post won't show it. That's expected, not a bug
in this codebase.

## Why Firebase App Distribution, not the app stores

`fastlane/Fastfile` distributes Android builds through Firebase App Distribution rather than the
Play Store or TestFlight. No Play Console or App Store Connect account is attached to this
project, and setting one up is a real, ongoing cost (a one-time Play Console fee, a $99/year
Apple Developer Program membership) that doesn't make sense purely to demonstrate the pattern.
Firebase App Distribution needs neither: this project already has two Firebase projects
(`flutter-enterprise-kit-dev`/`-prod`, set up for `auth`), so distribution lanes just reuse them.
It's also a genuinely standard real-world choice, most teams distribute internal/beta builds this
way before anything reaches a store, not a workaround invented just for this repo.

The `android` platform in the Fastfile gets full `build_dev`/`build_prod`/`distribute_dev`/
`distribute_prod` lanes. The `ios` platform only gets `build_dev`/`build_prod`, compiling with
`flutter build ios --no-codesign` to prove the app still builds for iOS, nothing more. Producing
an actual installable IPA (for Firebase App Distribution or anywhere else) requires a paid Apple
Developer Program account to generate a real provisioning profile; the free personal team used
earlier only satisfies Xcode's local code-signing requirement (see the macOS Keychain entitlement
note above), it can't produce a distributable build. This is a real constraint of the project's
current setup, documented rather than hidden, not a code problem to fix.

Release APKs are built with Flutter's default template signing (the debug key, with the `TODO`
comment Flutter's own template leaves in `android/app/build.gradle.kts`). That's fine for Firebase
App Distribution, testers install what you send them, but it would not be accepted by the Play
Store, which requires a real release keystore. Generating and safely wiring one (as a CI secret,
never committed) is real, separate work, listed in the README's Roadmap rather than folded in
here.
