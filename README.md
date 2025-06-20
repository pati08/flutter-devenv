# Flutter Development Environment
To get started, use `nix develop`.

The flake adds flutter to your dev environment and provides a nice CLI tool for easily starting up an emulator: `flutter-dev`. `flutter-dev` starts an emulator, sets up a trap to close it when finished, and runs your flutter app in interactive debug mode in the emulator. You can also just set up your own emulator and run `flutter run`.

## Prerequisites
You must already have `adb` and `kvm` or another VM system enabled in your `configuration.nix`
