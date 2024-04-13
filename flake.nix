{
  description = "A basic project in flutter";

  inputs = {
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat, android-nixpkgs }:
    flake-utils.lib.eachDefaultSystem ( system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk = {
              accept_license = true;
            };
          };
        };
        #androidEnvCustomPackage10 = pkgs.androidenv.androidPkgs_9_0;
        #androidEnvCustomPackage3 = pkgs.androidenv.composeAndroidPackages {
        #  buildToolsVersions = [ "34.0.0" "28.0.3" ];
        #  platformVersions = [ "34" "28" ];
        #  abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
        #};
        #androidEnvCustomPackage2 = pkgs.androidenv.composeAndroidPackages {};
        androidEnvCustomPackage = pkgs.androidenv.composeAndroidPackages {
          # cmdLineToolsVersion = 11.0;
          toolsVersion = "26.1.1";
          platformToolsVersion = "34.0.5";
          buildToolsVersions = [ "30.0.3" "34.0.0" ];
          includeEmulator = true;
          emulatorVersion = "34.1.9";
          platformVersions = [ "28" "29" "30" "31" "32" "33" "34" ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          cmakeVersions = [ "3.10.2" ];
          includeNDK = true;
          ndkVersions = [ "22.0.7026061" ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
        };
        androidCustomPackage = android-nixpkgs.sdk.${system} (
          sdkPkgs: with sdkPkgs; [
            cmdline-tools-latest
            build-tools-30-0-3
            build-tools-33-0-2
            build-tools-34-0-0
            platform-tools
            emulator
            #patcher-v4
            platforms-android-28
            platforms-android-29
            platforms-android-30
            platforms-android-31
            platforms-android-32
            platforms-android-33
            platforms-android-34
          ]
        );
        pinnedJDK = pkgs.jdk17; # jdk11, jdk13
      in {
        devShells = {
          default = pkgs.mkShell {
            name = "My-flutter-dev-shell";
            buildInputs = with pkgs; [
              flutter
              android-studio
            ] ++ [
              pinnedJDK
              #androidEnvCustomPackage.androidsdk
              androidCustomPackage
            ];
            #shellHook = ''
            #  GRADLE_USER_HOME=$HOME/gradle-user-home
            #  GRADLE_HOME=$HOME/gradle-home
            #'';
            JAVA_HOME = pinnedJDK;
            #ANDROID_HOME = "${androidEnvCustomPackage.androidsdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidCustomPackage}/share/android-sdk";
            #ANDROID_SDK_HOME = "${androidCustomPackage}/share/android-sdk";
            #ANDROID_SDK_ROOT = "${androidCustomPackage}/share/android-sdk";
            #ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
            #GRADLE_USER_HOME = "/home/specx/gradle-user-home";
            GRADLE_USER_HOME = "/home/specx/.gradle";
            #GRADLE_HOME = "/home/specx/gradle-home";
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidCustomPackage}/share/android-sdk/build-tools/34.0.0/aapt2";
          };
        };
      }
    );
}
