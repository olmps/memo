# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases here should only be made whenever there is a build available for them in the respective stores (even if it's
a beta or production release, they must be documented here).

## [Unreleased]

### Added
- Visually Opinionated Buttons (Primary, Secondary and Text).

## [0.2.0] - 2021-08-13

### Updated
- Several `ExecutionTerminal` enhancements:
  - Allows the user to go back/forward on the same memo.
  - The selected difficulty don't require a confirmation anymore - once it's selected, it animates to the next memo.

### Fixed
- Several `ExecutionTerminal` fixes:
  - Actions overlapping in smaller devices.
  - Inconsistent state when memos were executed too fast.
  - Not following the expected layout specs.
- Replaced oval gradient in `CollectionCard` with `LinearGradient`, attempting to solve performance issues.

### Removed
- Hero animation from `CollectionCard`.

## [0.2.0-rc.1] - 2021-08-02

### Added
- Firebase Analytics SDK with no need for consent - disabled `AdId` collection.
- A proper empty state for `CollectionsPage` - the `_CollectionsEmptyState`.
- `DestructiveButton`, a customized button for destructive operations - with custom layout specs.
- `MemoThemeData.destructiveSwatch` and a its respective destructive swatch for the classic theme.

### Updated
- Android & iOS Fastfiles to automatically distribute uploaded builds to external testers.
- Both `pull-request` and `release` workflows now:
  - Caches flutter's SDK.
  - Run Flutter tests only once.
  - Strategy used to authenticate with `GoogleService-Info` (only required in `release`, using an empty template in
  `pull-request`).
  - Uses the Flutter's beta channel + latest version, requirements of the animation jank fix.
- Android `minSdkVersion` from `16` to `17` and `multiDexEnabled` to `true`, requirements of `flutter-quill` dependency.
- iOS `MinimumOSVersion` from `8.0` to `9.0`, an apparent dependency on the latest beta channel version.
- Flutter's SDK to `2.4.0-4.2.pre` to fix the animation jank.
- `Fastfile` to use `--bundle-sksl-path` option, requirements of the animation jank fix.
- When quitting the execution, `CollectionExecutionPage` now uses the `showSnappableDraggableModalBottomSheet` instead
of `AlertDialog`.

#### Collections
- Cohesion improvements on `comecando_com_git`.

### Fixed
- Discord link was expired, now it's a permalink.
- White screen before `SplashPage` was loaded (using `flutter_native_splash` and generating native splash screens).
- `AssetIconButton` wasn't conforming to the correct layout specs.
- Misleading `QuillEditor` cursor in `readOnly` mode.
- Wrong iOS localization. `en` removed while we don't localize the app, only supports `pt-BR` for now.
- [Possible Fix] Trying to use a pre-bundled shader strategy to fix all animation's jank.
- `ExecutionTerminal` not respecting the device's safe area.

## [0.1.0] - 2021-07-16

### Added
- `bdd_fundamentos_01`, `fundamentos_scrum`, `guia_scrum`, `kotlin_fundamentos_01` and `manifesto_agil` collections.
Thanks to all contributors!

## [0.1.0-rc.3] - 2021-07-15

### Added
- `Contributor` model and its `ContributorSerializer` serializer.
- `EnvMetadata` and its respective implementation that provides application's environment constants.
- `SettingsSection.community` with `LinkSettingsItem` to discord.
- `showSnappableDraggableModalBottomSheet` utility.
- `MultiContributorsView` and `SingleContributorView` widgets.
- `Firebase` and `FirebaseCrashlytics` to record unexpected crashes, errors and exceptions.

### Updated
- All files documentations, including standardizing communication.
- `CollectionMemos` and `Collection` now have a `contributors` property, exposing all associated contributors with that
particular collection.
- `LoadedCollectionDetailsState` now also provides a list of `ContributorInfo` associated with that `Collection`.
- `LinkButton` widget now exposes `backgroundColor` and `textStyle` properties.
- `ExternalLinkButton` widget now exposes `iconColor`, `backgroundColor` and `textStyle` properties.
- `scaffold_messenger` to receive a `BuildContext` instead of extending it - improves code auto-completion.
- `Fastfile` to upload iOS symbols to Crashlytics.
- Existing collections with their respective contributors.

### Fixed
- Missing `SafeArea` in `Scaffold.bottomNavigationBar` for devices with home indicator.
- Missing `SettingsVM` interface.
- Hero animations built through `buildHeroCollectionCardFromItem` weren't using an unique `Hero.tag`.

## [0.1.0-rc.2] - 2021-05-12

### Added
- `comecando_com_git`, `ecossistema_do_flutter` and `swift_fundamentos_01` collections.

### Removed
- `git_getting_started` collection.

### Updated
- Added new resources to `resources.json`.

### Fixed
- Fixed [`release`](.github/workflows/release.yml) workflow to use personal access token when pushing changes to the
repo.

## [0.1.0-rc.1] - 2021-05-08

Introduces the first release candidate with all the first idealized functionalities for `memo`:

- Collections listing, which sections all collections using its category and segments the contents by explore and
review:
  - Explore shows all collections that haven't all memos completed at least once;
  - Review shows all collections that have all memos completed at least once.
- Progress, showing the user's metadata for application-wide collection's executions, such as time spent, the
percentage for each answer, etcetera;
- Collection details and execution, which allows the user to study upon a compiled collection in this repository;
- Settings page with info related to this project.

## [0.1.0-dev.1] - 2021-04-01

Initial release, defines core architecture.
The application is unusable on this version.