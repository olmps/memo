# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases here should only be made whenever there is a build available for them in the respective stores (even if it's
a beta or production release, they must be documented here).

## [Unreleased]

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