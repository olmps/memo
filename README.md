English | [Portuguese](README_ptbr.md)

# Memo

Monorepo for Memo.

Memo is an open-source, programming-oriented [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition)
software (SRS) written in Flutter.

<!--
You can use the latest beta features through TestFlight / Google Play, or download through:

AppStore (badge)
Google Play (badge)
-->

> As of now, this project is designed to only output builds for Android and iOS. Even though, given the current
> *stability* of Flutter SDK for desktop (Windows, Linux and macOS) and web, there is a high probability that this
> project will eventually support builds for all platforms.

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

## Architecture

How this application works from inside and how it interacts with external dependencies - written in details in 
[ARCHITECTURE.md](ARCHITECTURE.md).

## Background

This project was built with the help of the sponsors below:

WIP(sponsors)

If you're interested in checking out an overview about how we dealt with this project's software process (inside our team),
check out [.process/](.process/README.md) (sorry, for now only in ptBR).

## Contributing & Good Practices

See [CONTRIBUTING](CONTRIBUTING.md) for details about how to contribute to the project.

## License

Memo is published under [BSD 3-Clause](LICENSE).
