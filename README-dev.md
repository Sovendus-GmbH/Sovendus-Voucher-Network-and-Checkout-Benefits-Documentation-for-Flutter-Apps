# Sovendus Flutter Package - Development Setup

This guide will help you set up the development environment for the Sovendus Flutter package, even if you've never used Flutter before.

## What is Flutter?

Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. This project contains a Flutter package (library) that can be used by other Flutter apps.

## Project Structure

```
├── lib/                          # Main package source code
│   ├── sovendus_voucher_network_and_checkout_benefits.dart  # Main library file
│   └── src/                      # Internal source files
├── dev/                          # Development/testing app
│   ├── lib/                      # Test app source code
│   ├── pubspec.yaml             # Test app dependencies
│   └── ...                      # Platform-specific folders (android, ios, etc.)
├── pubspec.yaml                 # Main package dependencies
└── README-dev.md               # This file
```

## Prerequisites

### macOS Setup

1. **Install Flutter SDK**

   ```bash
   # Download Flutter SDK
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable

   # Add Flutter to your PATH (add this to ~/.zshrc or ~/.bash_profile)
   export PATH="$PATH:$HOME/development/flutter/bin"

   # Reload your shell
   source ~/.zshrc  # or source ~/.bash_profile
   ```

2. **Install Xcode** (for iOS development)
   - Download from Mac App Store
   - Run: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
   - Accept license: `sudo xcodebuild -runFirstLaunch`

3. **Install Android Studio** (for Android development)
   - Download from <https://developer.android.com/studio>
   - Install Android SDK and accept licenses:

     ```bash
     flutter doctor --android-licenses
     ```

4. **Install CocoaPods** (for iOS dependencies)

   ```bash
   sudo gem install cocoapods
   ```

### Linux Setup

1. **Install Flutter SDK**

   ```bash
   # Install required dependencies
   sudo apt update
   sudo apt install curl git unzip xz-utils zip libglu1-mesa

   # Download Flutter SDK
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable

   # Add Flutter to your PATH (add this to ~/.bashrc)
   export PATH="$PATH:$HOME/development/flutter/bin"

   # Reload your shell
   source ~/.bashrc
   ```

2. **Install Android Studio**

   ```bash
   # Download from https://developer.android.com/studio
   # Or install via snap:
   sudo snap install android-studio --classic

   # Accept Android licenses
   flutter doctor --android-licenses
   ```

## Verify Installation

Run Flutter doctor to check your setup:

```bash
flutter doctor
```

You should see checkmarks (✓) for the platforms you want to develop for. It's okay if some are missing if you don't need them.

## Getting Started

### 1. Clone and Setup the Project

```bash
# Navigate to the project directory
cd /path/to/sovendus-flutter-package

# Get dependencies for the main package
flutter pub get

# Navigate to the dev app and get its dependencies
cd dev
flutter pub get
```

### 2. Connect a Device

**For Android:**

- Enable Developer Options on your Android device
- Enable USB Debugging
- Connect via USB
- Check connection: `flutter devices`

**For iOS (macOS only):**

- Connect iPhone/iPad via USB
- Trust the computer when prompted
- Check connection: `flutter devices`

### 3. Run the Development App

```bash
# From the dev/ directory
cd dev

# List available devices
flutter devices

# Run on a specific device (replace DEVICE_ID with actual ID from flutter devices)
flutter run -d DEVICE_ID

# Or run on the first available device
flutter run
```

### 4. Development Workflow

The dev app imports the main package from `../lib/`, so any changes you make to the package source code will be reflected when you hot reload the app.

**Hot Reload:** Press `r` in the terminal while the app is running to see changes instantly.
**Hot Restart:** Press `R` to fully restart the app.
**Quit:** Press `q` to stop the app.

## Package Development

### Making Changes

1. Edit files in the main `lib/` directory
2. The dev app will automatically use your changes
3. Use hot reload (`r`) to see changes instantly

### Testing

```bash
# Run tests for the main package
flutter test
```

### Code Analysis

```bash
# Check for issues in the main package
flutter analyze

# Check for issues in the dev app
cd dev
flutter analyze
```

## Troubleshooting

### Common Issues

1. **"Flutter command not found"**
   - Make sure Flutter is in your PATH
   - Restart your terminal after adding to PATH

2. **"No devices found"**
   - For Android: Check USB debugging is enabled
   - For iOS: Check device is trusted
   - Run `flutter doctor` to diagnose

3. **Build errors**
   - Run `flutter clean` then `flutter pub get`
   - Check `flutter doctor` for missing dependencies

4. **iOS build issues (macOS)**
   - Make sure Xcode is installed and updated
   - Run `pod install` in the `dev/ios/` directory

### Getting Help

- Run `flutter doctor` to diagnose setup issues
- Check Flutter documentation: <https://docs.flutter.dev>
- Flutter community: <https://flutter.dev/community>

## Next Steps

Once you have the app running:

1. Explore the code in `lib/src/`
2. Make changes and see them reflected in the dev app
3. Add tests in the `test/` directory
4. Use the dev app to test different scenarios

The dev app demonstrates how to use the Sovendus package and serves as a testing ground for your changes.
