fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android build_dev

```sh
[bundle exec] fastlane android build_dev
```

Build the dev flavor debug APK

### android build_prod

```sh
[bundle exec] fastlane android build_prod
```

Build the prod flavor release APK

### android distribute_dev

```sh
[bundle exec] fastlane android distribute_dev
```

Build and distribute the dev flavor via Firebase App Distribution

### android distribute_prod

```sh
[bundle exec] fastlane android distribute_prod
```

Build and distribute the prod flavor via Firebase App Distribution

----


## iOS

### ios build_dev

```sh
[bundle exec] fastlane ios build_dev
```

Validate the dev flavor builds (no code signing)

### ios build_prod

```sh
[bundle exec] fastlane ios build_prod
```

Validate the prod flavor builds (no code signing)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
