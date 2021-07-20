# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases here should only be made whenever there is a build available for them in the respective stores (even if it's
a beta or production release, they must be documented here).

## [Unreleased]

## Updated
- Android & iOS Fastfiles to automatically distribute uploaded builds to external testers.

## [0.1.0] - 2021-07-16

## Added
- `bdd_fundamentos_01`, `fundamentos_scrum`, `guia_scrum`, `kotlin_fundamentos_01` and `manifesto_agil` collections.
Thanks to all contributors!

## [0.1.0-rc.3] - 2021-07-15

## Added
- `Contributor` model and its `ContributorSerializer` serializer.
- `EnvMetadata` and its respective implementation that provides application's environment constants.
- `SettingsSection.community` with `LinkSettingsItem` to discord.
- `showSnappableDraggableModalBottomSheet` utility.
- `MultiContributorsView` and `SingleContributorView` widgets.
- `Firebase` and `FirebaseCrashlytics` to record unexpected crashes, errors and exceptions.
  
## Updated
- All files documentations, including standardizing communication.
- `CollectionMemos` and `Collection` now have a `contributors` property, exposing all associated contributors with that
particular collection.
- `LoadedCollectionDetailsState` now also provides a list of `ContributorInfo` associated with that `Collection`.
- `LinkButton` widget now exposes `backgroundColor` and `textStyle` properties.
- `ExternalLinkButton` widget now exposes `iconColor`, `backgroundColor` and `textStyle` properties.
- `scaffold_messenger` to receive a `BuildContext` instead of extending it - improves code auto-completion.
- `Fastfile` to upload iOS symbols to Crashlytics.
- Existing collections with their respective contributors.

## Fixed
- Missing `SafeArea` in `Scaffold.bottomNavigationBar` for devices with home indicator.
- Missing `SettingsVM` interface.
- Hero animations built through  `buildHeroCollectionCardFromItem` weren't using an unique `Hero.tag`.

## [0.1.0-rc.2] - 2021-05-12

## Added
- `comecando_com_git`, `ecossistema_do_flutter` and `swift_fundamentos_01` collections.

## Removed
- `git_getting_started` collection.

## Updated
- Added new resources to `resources.json`.

## Fixed
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