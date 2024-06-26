# UniControlHub

<p align="center">
  <img src="https://github.com/rohitsangwan01/uni_control_hub/assets/59526499/6689d262-793a-44ec-bd5b-800d15ad2d25" height=150 />
</p>

UniControlHub: Seamlessly Bridge Your Devices

UniControlHub revolutionizes the way you interact with your digital environment by offering a seamless, intuitive control experience across multiple devices. Inspired by the convenience and fluidity of Apple's Universal Control, UniControlHub extends this innovative functionality beyond the Apple ecosystem. With just a single mouse and keyboard, you can effortlessly navigate and manage devices, UniControlHub ensures a cohesive and productive workspace. Built with Flutter for a smooth, responsive user experience, this app is the ultimate tool for enhancing productivity and streamlining your digital life.

![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

## Getting Started

Download app for your platform from [Release](https://github.com/rohitsangwan01/uni_control_hub/releases) section

App will ask for Accessibility and Bluetooth permission on MacOS

## Supported Platforms

| Platform | Bluetooth | USB |
| -------- | --------- | --- |
| IOS      | ✅        | ❌  |
| Android  | ⏳        | ✅  |

## Screenshot

<p align="start">
  <img src="https://github.com/rohitsangwan01/uni_control_hub/assets/59526499/7b2b87c3-4501-490b-a205-0e3815c4b583" height=400 />
</p>

## Demo

[![](http://markdown-videos-api.jorgenkh.no/youtube/KYsqdJkG2N0)](https://youtu.be/KYsqdJkG2N0)

## Troubleshooting

- If not working/crashing on Mac, try to install libusb `brew install libusb`
- If Mac asks for Accessibility permission on fresh install even if its already given, try to remove the app from Accessibility and run again
- To use UHID mode for Android, make sure `ADB` is installed ( not required for AOA mode )
- For Desktop and IOS connection, make sure Bluetooth is on
- After connecting Android device, click refresh button

## Developer's Guide

This section guides you through setting up and running UniControlHub for development purposes.

#### Prerequisites:

- Install the latest version of [Flutter](https://flutter-ko.dev/get-started/install) for your operating system. You can find instructions on the official Flutter website.
- Install [flutter_distributor](https://pub.dev/packages/flutter_distributor) to generate builds for different platforms.

#### Running/Debugging the App:

- Follow the [Flutter](https://flutter-ko.dev/get-started/install) setup guide for your platform. You can skip Android or iOS-specific steps if you're not developing for those platforms.
- Once Flutter is set up, run `flutter pub get` to download dependencies, and run `flutter run` to start the app

#### Generating Builds:

- MacOS: `flutter_distributor package --platform macos --targets dmg`

- Windows: `flutter_distributor package --platform windows --targets exe`

- Linux: `flutter_distributor package --platform linux --targets deb`

## Additional Notes:

UniControlHub uses the [Synergy server](https://github.com/symless/synergy-core) for cross-platform keyboard and mouse sharing. You can find more information about [Synergy](https://symless.com/synergy) on their website.

We welcome contributions to UniControlHub! If you find a bug or have a feature request, please open an issue on our GitHub repository.
