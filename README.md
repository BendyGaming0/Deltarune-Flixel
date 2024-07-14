# Deltarune-Flixel
 A Port of Deltarune's Core to HaxeFlixel with features like scripting

# Compiling from source code
 This guide assumes you already have the basic libraries for compiling a flixel application

 if you dont have flixel setup yet follow the steps on the HaxeFlixel [Getting Started](https://haxeflixel.com/documentation/getting-started/) guide

 Required Libraries:

    haxelib install flixel-addons
    haxelib install flixel-ui
    haxelib install hscript
    haxelib install hxdiscord_rpc

## Windows
 No extra setup is required for windows builds, as the project was made on windows.
## Android
 Download Android Studio and install the following

 - Android SDK Platform 30
 - Sources for Android 30
 - Android SDK Platform-Tools
 - Android SDK Build-Tools (Latest)
 - Android NDK r15c (This version is outdated and found at https://github.com/android/ndk/wiki/Unsupported-Downloads#ndk-15c-downloads)
 - Android Emulator (Recommended, not needed if you own an android device)

 Install Java JDK 11 (Recommended by the OpenFL/Lime team to use [Temurin](https://adoptium.net/))

 After which run the command `lime setup android`, most directories should be correct

 As of current, the release version of hxcpp encounters an error when compiling for android with for loop variable declaration

 To use the development version of hxcpp run the command `haxelib git hxcpp https://github.com/HaxeFoundation/hxcpp.git`

 You can use `haxelib set hxcpp VERSION_NUM` to switch between release and git versions

 If you encounter any issues related to compilation (compiler error not user error) you ask for help over at the official Haxe discord under the openfl-lime channel

 After compiling the .APK is located in `export\android\bin\app\build\outputs\apk\debug`