# Architecture

Table of contents
- [Architecture](#architecture)
  - [`.vscode/`](#vscode)
    - [Useful vscode extensions](#useful-vscode-extensions)
  - [`android/` - Android required files](#android---android-required-files)
  - [`ios/` - iOS required files- Architecture](#ios---ios-required-files--architecture)
  - [`lib/` - Flutter application](#lib---flutter-application)
    - [Why](#why)
    - [Overview](#overview)
    - [`application/`](#application)
      - [`constants/`](#constants)
      - [`pages/` (views)](#pages-views)
      - [`utils/`](#utils)
      - [`widgets/`](#widgets)
      - [`view_models/`](#view_models)
    - [`core/`](#core)
      - [`faults/`](#faults)
    - [`data/`](#data)
    - [`domain/`](#domain)
      - [`enums/`](#enums)
      - [`models/`](#models)
      - [`serializers/`](#serializers)
      - [`services/`](#services)
  - [`test/` - Unit and UI testing](#test---unit-and-ui-testing)
    - [`utils/`](#utils-1)
    - [`fixtures/`](#fixtures)
  - [`web/`](#web)
- [Extra](#extra)
  - [Why `river_pod` and not "x" state management library?](#why-river_pod-and-not-x-state-management-library)
  - [Why `sembast` and not "x" database?](#why-sembast-and-not-x-database)
  - [Why `mocktail` and not `mockito`?](#why-mocktail-and-not-mockito)
  - [`CoordinatorRouter` and `Router` (or Navigator 2.0)](#coordinatorrouter-and-router-or-navigator-20)
  - [Environment](#environment)
    - [Release](#release)

## `.vscode/`

While this project heavily enforces that vscode should be used, IntelliJ is also an alternative, although it won't
provide the best experience with the setup made in this repository. If you still prefer to use it, there should be no
problem at all, just make sure to follow the same guidelines specified in [`settings.json`](.vscode/settings.json).

All configuration files exist in [`.vscode`](.vscode/) folder and **should be git-tracked**.

  - [`launch.json`](.vscode/launch.json) is where all pre-configured command-line scripts are at, such as running a
  debug dev environment;
  - [`settings.json`](.vscode/settings.json) is responsible for the editor configurations, such as line-length, rules
  and auto-format on save.

### Useful vscode extensions

- Dart (id: dart-code.dart-code);
- Flutter (id: dart-code.flutter);
- Awesome Flutter Snippets (id: nash.awesome-flutter-snippets) - frequently used snippets in any Flutter application;
- Brack Pair Color (id: coenraads.bracket-pair-colorizer) - useful when dealing with nested/verbose widgets.

It's highly recommended to, at least, add the `Dart` and `Flutter` extension, as they provide an absurd amount of useful
features.

> You can copy the id and search in the vscode marketplace to find them.

## `android/` - Android required files

Stores all required (and generated) files to output builds for the Android platform.

This is where native Android (Kotlin) code also lives, if there is a need to implement native-specific features.

## `ios/` - iOS required files- [Architecture](#architecture)

Stores all required (and generated) files to output builds for the iOS/iPadOS platforms.

This is where native iOS (Swift) code also lives, if there is a need to implement native-specific features.

## `lib/` - Flutter application

Entry point to the Flutter application, where most of the *action* will happen.

### Why

> You can skip this explanation, this is just an overview on the topic of why we have decided to go with this particular
> architectural approach.

At first glance (looking at the name of the topmost folders), with the objective of defining its layers and the
respective interactions, you may question yourself if this project is using
[clean architecture](http://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html), 
[domain driven design (DDD)](https://martinfowler.com/bliki/DomainDrivenDesign.html) or even some pieces of
[MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel). Now, when you start reading it and finding
out which part depends on what - and what they expect to execute their responsibilities -, you may wonder about things
like "entities are not mapped to models!", "where are the use-cases?" and questions about the fact that this approach
**doesn't follow these architectures principles**. Why is that?

Well, clean architecture was originally intended for robust/enterprise-like applications that have to deal with a ton of
business-logic complexity and highly-verbose dependencies - such as libraries, frameworks and any external resources.
While this is a frequent scenario in the present state of software applications, **this project is definitely not the
case of a highly-complex scenario** - it may evolve to be complex enough, but it won't exceed the complexity of being a
REST-consuming client that **focuses** much more on the presentation layer than anything else.

Nowadays, simpler architectural designs like MVC/MVVM/MVP are much more common in client applications due to this exact
fact: a overcomplex and high boilerplate architecture doesn't provide any significant value - they make things harder
and slower with no clear benefit other than separating a bunch of layers **for the sake of separating them**. But they
come with a price: there is no clear distinction in between **Business Logic and Data manipulation** if you don't
enforce such standards.

No, we won't remove the classic separation of "View <-> Business Logic <-> Data" relationship, it's just that, in this
case, **we think that following every nook and cranny of part of these architectures would be overengineering**, thus
making things slower just to follow some principles that don't necessarily applies to this case. This approach will
surely not make sense (or even be completely dumb) for some, but may be good for others.
[Relevant xkcd](https://xkcd.com/927/).

One extra thing: this is heavily influenced by a bunch personal opinions and experiences in some production projects
that the team has worked on. This project's external dependencies will keep changing as the time goes on, Flutter will
also keep evolving, and we have to adapt in a way to maintain consistency, integrity and scalability of our solution.
So, it's probable that there is (or will be) better ways to achieve the same goals/objectives, and for this, we look
into your help to make this project's architecture continuously provide a good developer experience to add new features,
update old ones and keep those nasty bugs away.

### Overview

![Architecture Overview](.resources/00arch_overview.png "Architecture Overview")

The picture above gives us an overview of each abstraction layer that gives shape to this application - alongside its
interactions/dependencies. Keep in mind that this is a simplified version, so most of the dependency arrows (those
connecting elements, like *view models -> services*) should follow the dependency inversion principle.

If you don't want to dig in on what each part is responsible of (and why), here is a TLDR:
  - `application`: all interface elements alongside its view models (may contain validation and such business logic), 
  the latter which communicates with the `domain`;
  - `domain`: handles most of the business logic and, if necessary, make the respective calls to the `data` layer;
  - `data`: retrieves and modifies any data, without the knowledge of any other layers whatsoever. This is the
  lower-boundary of our application that communicates with external frameworks and libraries;
  - `core`: shared functionality to all layers.

### `application/`

Our topmost layer, the entry point of all user interactions, which depends directly on Flutter to function properly.
The `application` should be responsible only for rendering elements and capturing inputs, touches, and any interaction
that comes directly from the user, alongside the interface's capabilities, like scroll, navigation, responsivity,
etcetera.

Rules about each `application/` file's responsibilities:
- It should never interact with any layer other than its own sub-folders;
- It should never access any other layer classes (not even indirectly), unless it's a [`domain/enums`](#enums), which
we consider to be acceptable.

The only structures which this doesn't apply, are the **[ViewModels (VMs)](#view_models)**.

#### `constants/`

Stores any kind of constant, like images, strings, themes, etcetera.

#### `pages/` (views)

Each page is normally associated with a `Scaffold`, that represents all the contents of a single `MaterialPageRoute`,
which is controlled by the `CoordinatorRouter`.

These `pages` are the only elements that can access the [`view_models/`](#view_models).

#### `utils/`

UI-related utilities like formatting, widgets helpers, animations, painters, etcetera.

#### `widgets/`

Individual `Widget`s that represent some custom visual element that is reused in multiple different
[`pages`](#pages-views) or even other `application/widgets`. These should not know anything about VMs, pages, or
anything other than `application/utils` and `application/constants`. They should be **pure** and **independent**.

#### `view_models/`

The boundary between the [`application/`](#application) and [`domain/`](#domain). The ViewModels, (suffixed with `VM`
in each class), always should be built upon an interface (for testability) and should never - ever - know anything about
the UI, meaning, the `flutter` framework, other than some constant stuff like `Platform` and core meta-functionality,
but never anything related to the layout per-se.

The `VM`s are the only pieces in [`application/`](#application) that communicates with inner layers, more specifically,
with the [`domain/`](#domain) and, in the process of achieving this, it will inevitably leak some of the core business
logic (things like input validation) that should be mostly contained in the [`domain/`](#domain) layer.

### `core/`

Fundamental functionality to all the layers, being accessed by any of them, but doesn't know about their existance.
In terms of knowledge, they are similar to the [`data`](#data) layer, other than the fact that the `data` layer itself
can access the `core`.

The core shares functionality like [`faults/`](#faults), environment management, project-wide constants, etcetera.

#### `faults/`

Has all the project's custom `Error`s and `Exception`s classes.

### `data/`

Our bottom layer, communicates with raw libraries and frameworks to consume its raw data and expose it to its consumer.
These libraries and frameworks are abstractions (interfaces) to access things like remote servers, hardware capabilities
(audio, video, geo), databases, etcetera. Each of these "accessors" are suffixed with `Repository`.

Rules about each `data/` file's responsibilities:
- It should never interact with any layer other than its own sub-folders.

### `domain/`

Our middle layer. Using the core structures (models, entities and enums), the domain is where all the business logic
should be contained, by accessing the repositories to achieve its goals.

Rules about each `domain/` file's responsibilities:
- It should never interact with any layer other than its own sub-folders.

The only structures which this doesn't apply, are the **[Services](#services)**.

#### `enums/`

They are just like our [`models`](#models), they are a data structure that represent part of our business, but with the
difference that it can be described statically (they are constant).

> These are the only structures that can be accessed (or leaked) to the views due to its constant nature. It provides a
> type-safety when dealing with these cases and, if we don't actually leak it, normally what we have is a duplication of
> this same enumerator behavior in the UI, but less type-safe.

#### `models/`

A domain model - a set of structures that represent a business object.

> Point of possible failure for future changes: These models are dependant on the interface of a class in the
> `data` layer, more specifically the `KeyStorable` class. This is intended because it benefits us to have a single
> generic `DatabaseRepository` at the cost of needing to refactor all models if all of the `DatabaseRepository`
> structure also changes (like a really big change, not a common one).

#### `serializers/`

Instead of a codegen approach (due to the drawbacks of being dependent of auto-generating the parsing of our core
models), we decided to go with the manual serialization. The `serializers/` exist with the sole purpose of translating
[`models/`](#models) to/from a raw structure.

> Point of possible failure for future changes: These serializers are dependant on the interface of a class in the
> `data` layer, more specifically the `JsonSerializer` class. This is intended because it benefits us to have a single
> generic `DatabaseRepository` at the cost of needing to refactor all serializers if all of the `DatabaseRepository`
> structure also changes (like a really big change, not a common one).

#### `services/`

The boundary between the [`domain/`](#domain) and [`data/`](#data). Each service (suffixed with `Service` in each
class) should always be built upon an interface (for testability).

The `services/` should contain all the heavy business logic associated with each `model` in our project. They are
usually split to represent each [`models/`](#models) related business logic, but this could be split in even smaller
pieces (called Use Cases in the clean architecture) if proven necessary.

## `test/` - Unit and UI testing

Nothing out of the ordinary here, we simply make a mirror of the `lib/` folder structure within `test/`. I.e. if we have
a file that is `lib/application/widgets/custom_container.dart`, we would have a mirrored
`test/application/widgets/custom_container_test.dart`.

Due to some [limitations of the dart language](https://github.com/dart-lang/language/issues/1482) and the new
null-safety approach, [`mockito`](https://github.com/dart-lang/mockito) is now using a codegen to mock, which we
honestly think that [`mocktail`](https://github.com/felangel/mocktail) is a better alternative.

### `utils/`

Shared functionality amongst all test cases.

### `fixtures/`

Tests [fixtures](https://en.wikipedia.org/wiki/Test_fixture#Software) - here is a
[good SO answer](https://stackoverflow.com/a/14684400/8558606) explaining what they represent. In our scenario, they
usually represent raw data, models or entities.

## `web/`

Stores all required (and generated) files to output builds for the Web platform. Currently not supported.

---

# Extra

These are points that aren't directly related to the folder structure and each responsibility, but things that also
permeates the knowledge required to fully understand this architecture.

## Why `river_pod` and not "x" state management library?

WIP

## Why `sembast` and not "x" database?

WIP

## Why `mocktail` and not `mockito`?

WIP

## `CoordinatorRouter` and `Router` (or Navigator 2.0)

WIP

## Environment

For different types of build environments, we don't use the common _flavors_, iOS schemas and all of that painful setup,
due to the fact that, since Flutter `1.17`, we can now use command arguments to inject any variable in our application -
no more multiple `main.dart` files and such stuff. Simply run:

`flutter run --dart-define=ENV=MY_ENVIRONMENT`

If you are using `vscode` IDE, there is the [launch configuration files](.vscode/launch.json) for you to auto run and
debug the application.

And that's it, the currently supported environments are: `DEV` and `PROD`.

### Release

WIP