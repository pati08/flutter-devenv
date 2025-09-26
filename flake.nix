{
  description = "Flutter devshell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };
      ndkVersion = "27.0.12077973";
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        toolsVersion = "26.1.1";
        platformToolsVersion = "34.0.5";
        buildToolsVersions = [ "34.0.0" ];
        includeEmulator = true;
        emulatorVersion = "34.1.9";
        platformVersions = [ "36" ];
        includeSources = false;
        includeSystemImages = false;
        systemImageTypes = [ "google_apis_playstore" ];
        abiVersions = [ "x86_64" ];
        cmakeVersions = [ "3.22.1" ];
        includeNDK = true;
        ndkVersions = [ ndkVersion ];
        useGoogleAPIs = false;
        useGoogleTVAddOns = false;
      };
      androidSdk = androidComposition.androidsdk;

      emulatorPkg = pkgs.androidenv.emulateApp {
        name = "emulate-MyAndroidApp";
        platformVersion = "36";
        abiVersion = "x86_64";
        systemImageType = "google_apis_playstore";
        deviceName = "pixel_9";
      };

      flutterDevPkg = pkgs.writeShellScriptBin "flutter-dev" ''
        set -euo pipefail

        export ANDROID_SDK_ROOT="''${ANDROID_SDK_ROOT:-${androidSdk}/libexec/android-sdk}"

        echo "Starting emulator..."
        "${emulatorPkg}/bin/run-test-emulator" > /dev/null 2>&1 &
        emulator_pid=$!
        trap 'kill $emulator_pid' EXIT

        echo "Waiting for emulator to boot..."
        while ! adb wait-for-device shell getprop sys.boot_completed | grep -q "1"; do
        sleep 1
        done

        echo "Emulator booted, running Flutter..."
        exec flutter run
      '';
    in
    {
      devShell = with pkgs;
        mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          buildInputs = [
            flutter
            androidSdk # The customized SDK that we've made above
            jdk17
          ];
          shellHook = ''
            export PATH=${flutterDevPkg.outPath}/bin:$PATH
            export PATH=${emulatorPkg}/bin:$PATH
          '';
        };
    });
}
