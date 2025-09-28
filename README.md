# Country Code Max

A beautiful, animated, and theme-aware country code picker for Flutter that works seamlessly across web and mobile platforms.

## Features

- 🎨 **Beautiful Animations** - Smooth transitions and micro-interactions
- 🌓 **Theme Aware** - Automatically adapts to light and dark themes
- 📱 **Cross Platform** - Works seamlessly on web and mobile
- 🔍 **Smart Search** - Search by country name, code, or dial code
- ⭐ **Favorites** - Mark frequently used countries as favorites
- 🏳️ **Country Flags** - Beautiful flag display with fallback icons
- 🎯 **Customizable** - Easy to modify colors, sizes, and behavior

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  country_code_max: ^1.0.0
```

## Usage

### Basic Usage

```dart
import 'package:country_code_max/country_code_max.dart';

AnimatedCountryCodePicker(
  onCountrySelected: (country) {
    print('Selected: ${country.name} (${country.dialCode})');
  },
)
```

### Advanced Usage

```dart
AnimatedCountryCodePicker(
  initialCountryCode: "US",
  favorites: ["US", "IN", "GB", "CA", "AU"],
  showSearchBar: true,
  showFlags: true,
  showDialCode: true,
  searchHint: "Search countries...",
  label: "Country Code",
  isRequired: true,
  errorText: "Please select a country",
  onCountrySelected: (country) {
    setState(() {
      selectedCountry = country;
    });
  },
)
```

### Without Flags

```dart
AnimatedCountryCodePicker(
  showFlags: false,
  onCountrySelected: (country) {
    // Handle selection
  },
)
```

## API Reference

### AnimatedCountryCodePicker

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `initialCountryCode` | `String?` | `null` | Initial country code to select |
| `favorites` | `List<String>?` | `null` | List of favorite country codes |
| `showSearchBar` | `bool` | `true` | Whether to show search bar |
| `showFlags` | `bool` | `true` | Whether to show country flags |
| `showDialCode` | `bool` | `true` | Whether to show dial code in picker |
| `searchHint` | `String?` | `"Search countries..."` | Search bar hint text |
| `label` | `String?` | `null` | Label text above picker |
| `isRequired` | `bool` | `false` | Whether field is required |
| `errorText` | `String?` | `null` | Error text to display |
| `height` | `double?` | `56.0` | Picker height |
| `width` | `double?` | `null` | Picker width |
| `onCountrySelected` | `Function(CountryCode)?` | `null` | Callback when country is selected |

### CountryCode

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String` | Country name |
| `code` | `String` | Country code (e.g., "US") |
| `dialCode` | `String` | Dial code (e.g., "+1") |
| `flag` | `String?` | Flag asset path |

## Examples

### Phone Number Input

```dart
Row(
  children: [
    SizedBox(
      width: 120,
      child: AnimatedCountryCodePicker(
        initialCountryCode: "US",
        favorites: ["US", "IN", "GB"],
        onCountrySelected: (country) {
          setState(() {
            selectedCountry = country;
          });
        },
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: TextField(
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Phone number',
        ),
      ),
    ),
  ],
)
```

### Form Validation

```dart
AnimatedCountryCodePicker(
  label: "Country Code",
  isRequired: true,
  errorText: _selectedCountry == null ? "Please select a country" : null,
  onCountrySelected: (country) {
    setState(() {
      _selectedCountry = country;
    });
  },
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you like this package, please give it a ⭐ on GitHub!
