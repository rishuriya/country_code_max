# Installation Guide

## Option 1: Local Package (Recommended for Development)

1. **Copy the package folder** to your project:
   ```bash
   cp -r country_code_max /path/to/your/flutter/project/packages/
   ```

2. **Add to pubspec.yaml**:
   ```yaml
   dependencies:
     country_code_max:
       path: packages/country_code_max
   ```

3. **Run flutter pub get**:
   ```bash
   flutter pub get
   ```

## Option 2: Git Dependency

Add to your `pubspec.yaml`:
```yaml
dependencies:
  country_code_max:
    git:
      url: https://github.com/your-username/country_code_max.git
      ref: main
```

## Option 3: Pub.dev (When Published)

Add to your `pubspec.yaml`:
```yaml
dependencies:
  country_code_max: ^1.0.1
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
import 'package:country_code_max/country_code_max.dart';

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
cd country_code_max/example
flutter run
```
