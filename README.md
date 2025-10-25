# UniControlHub

[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/rohitsangwan01)
![Downloads](https://img.shields.io/github/downloads/rohitsangwan01/uni_control_hub/total.svg)

<p align="center">
  <img src="https://github.com/user-attachments/assets/41c886c0-f08c-4186-bc98-153aa2769d13" height=150 />
</p>

UniControlHub: Seamlessly Bridge Your Devices

UniControlHub revolutionizes the way you interact with your digital environment by offering a seamless, intuitive control experience across multiple devices. Inspired by the convenience and fluidity of Apple's Universal Control, UniControlHub extends this innovative functionality beyond the Apple ecosystem. With just a single mouse and keyboard, you can effortlessly navigate and manage devices, UniControlHub ensures a cohesive and productive workspace. Built with Flutter for a smooth, responsive user experience, this app is the ultimate tool for enhancing productivity and streamlining your digital life.

![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

<a href="https://buymeacoffee.com/rohitsangwan" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


## Getting Started

Download app for your platform from [Release](https://github.com/rohitsangwan01/uni_control_hub/releases) section

### MacOS

- Install libusb: `brew install libusb`

### Windows

- Install `Microsoft Visual C++ 2015-2022` for your [x86](https://aka.ms/vs/17/release/vc_redist.x86.exe) or [x64](https://aka.ms/vs/17/release/vc_redist.x64.exe) OS.

- If Android device not getting detected, make sure you have libusb [drivers](https://github.com/libusb/libusb/wiki/Windows#driver-installation) installed.

### Linux

Make sure On `libqt5dbus5` is installed

Ubuntu/Debian-based systems, run:

```bash
sudo apt update
sudo apt install libqt5dbus5
```

On Fedora/RHEL/CentOS, run:

```bash
sudo dnf install qt5-qtbase
```

On Arch Linux, run:

```bash
sudo pacman -S qt5-base
```

## Supported Platforms

| Platform | Bluetooth | USB | ADB |
| -------- | --------- | --- | --- |
| IOS      | ✅        | ❌  | ❌  |
| Android  | ⏳        | ✅  | ✅  |

## Screenshot

<p align="start">
  <img src="https://github.com/rohitsangwan01/uni_control_hub/assets/59526499/7b2b87c3-4501-490b-a205-0e3815c4b583" height=400 />
</p>

## Demo

[![](http://markdown-videos-api.jorgenkh.no/youtube/KYsqdJkG2N0)](https://youtu.be/KYsqdJkG2N0)

## Troubleshooting

- On MacOS, App will ask for `Accessibility` and `Bluetooth` permission on MacOS, ( After updating, app might again ask for Accessibility permission, even if its already given, try to remove the app from Accessibility and run again )
- To use UHID mode for Android, make sure `ADB` is installed ( not required for AOA mode )
- For Desktop and IOS connection, make sure Bluetooth is on
- After connecting Android device, click refresh button

## Developer's Guide

This section guides you through setting up and running UniControlHub for development purposes.

#### Prerequisites:

- Install the latest version of [Flutter](https://flutter-ko.dev/get-started/install) for your operating system. You can find instructions on the official Flutter website.
- Follow the [Flutter](https://flutter-ko.dev/get-started/install) setup guide for your platform. You can skip Android or iOS-specific steps if you're not developing for those platforms.

#### Running/Debugging the App:

- Once Flutter is set up, run `flutter pub get` to download dependencies, and run `flutter run` to start the app

## Sponsor

If you find this project useful, consider sponsoring it! Your support helps keep development active, adds new features, and improves stability. You can also share your ideas or feedback in the [Discussions](https://github.com/rohitsangwan01/uni_control_hub/discussions). Thanks for your support! 🚀

[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/rohitsangwan01)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/rohitsangwan)

## Additional Notes:

UniControlHub uses the [Synergy server](https://github.com/symless/synergy-core) for cross-platform keyboard and mouse sharing. You can find more information about [Synergy](https://symless.com/synergy) on their website.

We welcome contributions to UniControlHub! If you find a bug or have a feature request, please open an issue on our GitHub repository.
