# Installation Guide

## Option 1: Local Package (Recommended for Development)

1. **Copy the package folder** to your project:
   ```bash
   cp -r country_code_picker_plus /path/to/your/flutter/project/packages/
   ```

2. **Add to pubspec.yaml**:
   ```yaml
   dependencies:
     country_code_picker_plus:
       path: packages/country_code_picker_plus
   ```

3. **Run flutter pub get**:
   ```bash
   flutter pub get
   ```

## Option 2: Git Dependency

Add to your `pubspec.yaml`:
```yaml
dependencies:
  country_code_picker_plus:
    git:
      url: https://github.com/your-username/country_code_picker_plus.git
      ref: main
```

## Option 3: Pub.dev (When Published)

Add to your `pubspec.yaml`:
```yaml
dependencies:
  country_code_picker_plus: ^1.0.0
```

## Required Dependencies

Make sure you have these dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_screenutil: ^5.9.0
  google_fonts: ^6.1.0
```

## Usage

```dart
import 'package:country_code_picker_plus/country_code_picker_plus.dart';

// In your widget
AnimatedCountryCodePicker(
  onCountrySelected: (country) {
    print('Selected: ${country.name} (${country.dialCode})');
  },
)
```

## Example App

Run the example app to see the package in action:

```bash
cd country_code_picker_plus/example
flutter run
```
