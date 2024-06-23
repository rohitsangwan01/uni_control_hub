# UniControlHub

<p align="center">
  <img src="https://github.com/rohitsangwan01/uni_control_hub/assets/59526499/de4ceb30-9b59-4306-ad49-d4550811809b" height=150 />
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
  <img src="https://github.com/rohitsangwan01/uni_control_hub_app/assets/59526499/de386a99-6d09-45aa-b760-96204d882ce4" height=400 />
</p>

## Demo

[![](http://markdown-videos-api.jorgenkh.no/youtube/KYsqdJkG2N0)](https://youtu.be/KYsqdJkG2N0)

## Generate builds

Install [flutter_distributor](https://pub.dev/packages/flutter_distributor) and run

MacOS: `flutter_distributor package --platform macos --targets dmg`

Windows: `flutter_distributor package --platform windows --targets exe`

Linux: `flutter_distributor package --platform linux --targets deb`

## Note

A special thanks to [synergy-core](https://github.com/symless/synergy-core) for the cross-platform keyboard and mouse sharing tool binaries, If your goal is to share a mouse and keyboard across multiple desktops, i highly recommend checking out [Synergy](https://symless.com/synergy).

This is initial version, feel free to report bugs
