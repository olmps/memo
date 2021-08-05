# Flutter

Source files for Memo's Flutter application.

> At this moment, Memo only output builds for Android and iOS, although - **eventually** - there may be a support for 
> desktop (Windows, Linux and macOS) and web, all using Flutter!

## Setup

1. If you have no idea how to install Flutter and run it locally, check this
[_Get started_](https://flutter.dev/docs/get-started/install).
2. If you have Flutter setup locally, install pubspec dependencies by running `flutter pub get` in `flutter/` root
folder.
3. Setup Firebase dependencies. More information on this in [ARCHITECTURE#firebase](flutter/ARCHITECTURE.md#firebase).


... and you're good to go - just run in any physical device, or a simulator/emulator.

## Architecture

You can find out more in [ARCHITECTURE.md](ARCHITECTURE.md). There - be advised -, we go in verbose mode. It is a manual
to anyone that wants to contribute to this project, or to simply understand why we made the decisions that defines this
application's architecture.

Don't forget to check out both [General ARCHITECTURE.md](../ARCHITECTURE.md) and
[Firebase ARCHITECTURE.md](../firebase/ARCHITECTURE.md), which also impact on how the Flutter application is structured.