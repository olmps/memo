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
software (SRS) - created using Flutter and Firebase.

<div style='display: flex; align-items: center;'>
  <a href="https://apps.apple.com/br/app/memo-estude-programa%C3%A7%C3%A3o/id1565438866?itsct=apps_box_badge&amp;itscg=30200">
    <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83&amp;releaseDate=1626393600&h=43060d9f55f8fc9034f8109bd6bbe56e" alt="Download on the App Store" style="height: 83px;" />
  </a>

  <a href='https://play.google.com/store/apps/details?id=com.olmps.memoClient&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'>
    <img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' style="width: 250px;" />
  </a>
</div>

... or you can use the latest - beta - functionalities through:
- [TestFlight - iOS](https://testflight.apple.com/join/Xc33YcGa).
- [Google Play Beta Testing - Android](https://play.google.com/apps/testing/com.olmps.memoClient).

---

This README is meant to guide how this project is structured and should serve as a guide to help the project scale with
the current and future requirements. Think of it as a flexible set of rules that guides the project's decisions. While
they can (and probably will) change over time, discussions must be raised to trigger such changes: this means that
we will think/question ourselves before taking an action that breaks any rational decision taken here. It is also
effective to guide PR discussions.

- [Setup](#setup): how to configure your local project;
- [Architecture](#architecture): how this application works from inside;
- [Background](#background): some background story about this project;
- [Contributing & Good Practices](#contributing--good-practices): recommendation on how to write good code for this
  application;
- [License](#license): how this software is licensed and how you may use it.
- [Sponsors](#sponsors): who helped us to make this project a reality.

## Setup

<!-- TODO(matuella): Add links referencing such setups after both are done -->

It shouldn't be hard to run your own Memo setup locally, but you'll have to add Firebase in both [`firebase/`]() and
[`flutter/`]() projects. These are really simple steps, but the TLDR is that you'll have to create a Firebase project;
deploy the infrastructure specified in `firebase/`; and add the required Firebase files to run your own server/client
instances.

## Architecture

The root [ARCHITECTURE.md](ARCHITECTURE.md) gives an overview of this application's architecture, although if you want
to know how Memo works from the inside, go check out both [Flutter's ARCHITECTURE](flutter/ARCHITECTURE.md) and
[Firebase's ARCHITECTURE](firebase/ARCHITECTURE.md) - these go through all of the nitty-gritty of each language toolkit,
in-application layers (and its interactions), non-standard decisions, etcetera - literally explaining every major
decision for each "ecosystem".

## Background

If you're interested in checking out an overview - of the first release, client-side only - about how we dealt with this
project's software process, check out [.process/](.process/README.md) (sorry, only in ptBR).

## Contributing & Good Practices

See [CONTRIBUTING](CONTRIBUTING.md) for details about how to contribute to the project.

## License

Memo is published under [BSD 3-Clause](LICENSE).

## Sponsors

This project was built with the help of the sponsors below:

- [Maratona Discover](https://bit.ly/lucas-montano-maratonadiscover): Discover is a free way of learning how to code.
- [Startup Life Podcast](https://bit.ly/lucas-montano-startup-life): Your tech, business, and innovation Podcast.
- [Pingback](https://bit.ly/lucas-montano-pingback): Total freedom to create content.
