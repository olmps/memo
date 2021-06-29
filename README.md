English | [Portuguese](README_ptbr.md)

<div align="center">
  <h1>Memo</h1>
  <img src="https://raw.githubusercontent.com/olmps/memo/master/assets/icon.png" alt="Memo Icon" width="200">
  <br>
  <br>
  <a href="https://github.com/olmps/memo/actions/workflows/release.yml">
    <img src="https://github.com/olmps/memo/actions/workflows/release.yml/badge.svg" alt="Release">
  </a>
  <br>
  <br>
</div>

Monorepo for Memo.

Memo is an open-source, programming-oriented [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition)
software (SRS) written in Flutter.

> As of now, this project is designed to only output builds for Android and iOS. Even though, given the current
> _stability_ of Flutter SDK for desktop (Windows, Linux and macOS) and web, there is a high probability that this
> project will eventually support builds for all platforms.

---

This README is meant to guide how this project is structured and should serve as a guide to help the project scale with
the current and future requirements. Think of it as a flexible set of rules that guides the project's decisions. While
they can (and probably will) change over time, discussions must be raised to trigger such changes: this means that
we will think/question ourselves before taking an action that breaks any rational decision taken here. It is also
effective to guide PR discussions.

- [Setup](#setup): how the configure your local project;
- [Architecture](#architecture): how this application works from inside;
- [Background](#background): some background story about this project;
- [Contributing & Good Practices](#contributing--good-practices): recommendation on how to write good code for this
  application;
- [License](#license): how this software is licensed and how you may use it.

## Setup

If you have no idea how to install Flutter and run it locally, check this
[_Get started_](https://flutter.dev/docs/get-started/install).

If you have Flutter setup locally, on the project's root folder, install pubspec dependencies by running
`flutter pub get`.

### Firebase dependencies

Memo has Firebase dependencies that require a setup before the project can be run locally. The original 
`GoogleServices-Info.plist` (iOS) and `google-services.json` (Android) are not checked in source control, which means 
that you must provide your own Firebase project google service files to run the app.

If you want to know how to setup your own Firebase project, check out the 
[FlutterFire docs](https://firebase.flutter.dev/docs/overview/).

## Architecture

How this application works from inside and how it interacts with external dependencies - written in details in
[ARCHITECTURE.md](ARCHITECTURE.md).

## Background

This project was built with the help of the sponsors below:

If you're interested in checking out an overview about how we dealt with this project's software process (inside our team),
check out [.process/](.process/README.md) (sorry, for now only in ptBR).

## Contributing & Good Practices

See [CONTRIBUTING](CONTRIBUTING.md) for details about how to contribute to the project.

## License

Memo is published under [BSD 3-Clause](LICENSE).

## Sponsors

- [Maratona Discover](https://bit.ly/lucas-montano-maratonadiscover): Discover is a free way of learning how to code.
- [Startup Life Podcast](https://bit.ly/lucas-montano-startup-life): Your tech, business, and innovation Podcast.
- [Pingback](https://bit.ly/lucas-montano-pingback): Total freedom to create content.
