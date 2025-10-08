# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-10-08
### Added
- **Major expansion of country database** with 100+ additional countries:
  - **North America**: Mexico, Greenland, Bermuda
  - **Central America**: Belize, Costa Rica, El Salvador, Guatemala, Honduras, Nicaragua, Panama
  - **Caribbean**: Jamaica, Trinidad and Tobago, Barbados, Bahamas, Cuba, Haiti, Dominican Republic, Puerto Rico, Saint Lucia, Grenada, Dominica, Antigua and Barbuda, Saint Kitts and Nevis, Saint Vincent and the Grenadines, Aruba, Cayman Islands, Turks and Caicos Islands
  - **South America**: Argentina, Chile, Colombia, Peru, Venezuela, Ecuador, Uruguay, Paraguay, Bolivia, Guyana, Suriname, French Guiana
  - **Asia & Pacific**: North Korea, Mongolia, Vietnam, Thailand, Myanmar (Burma), Laos, Cambodia, Malaysia, Singapore, Indonesia, Philippines, Brunei, Timor-Leste
  - **Central Asia**: Kazakhstan, Uzbekistan, Turkmenistan, Kyrgyzstan, Tajikistan
  - **Oceania & Pacific**: Fiji, Papua New Guinea, Samoa, Tonga, Vanuatu, Solomon Islands, Kiribati, Tuvalu, Micronesia, Marshall Islands, Nauru, Palau
  - **Europe**: Ukraine, Belarus, Serbia, Bosnia and Herzegovina, North Macedonia, Montenegro, Albania, Turkey
- Organized country list with regional comments for better maintainability
- Comprehensive coverage of all major world regions

### Changed
- Enhanced country data structure with improved organization
- Expanded from ~100 to 200+ countries for global coverage

## [1.0.1] - 2025-09-29
### Added
- Added missing countries to dataset (e.g., Nepal `NP` `+977`, Bhutan, Maldives, Sri Lanka, Bangladesh, Pakistan, Afghanistan, and Gulf countries).
- New unit test to assert Nepal exists with correct dial code to prevent regressions.
- Dartdoc comments for public API: `CountryCode`, `CountryData`, `CountryCodePicker`, `AnimatedCountryCodePicker`, `CountryCodePickerModal`, and package library file.

### Changed
- Replaced deprecated `withOpacity(...)` usages with `withValues(alpha: ...)` across widgets and example.
- Improved documentation coverage above 20%.

### Fixed
- Ensured country list completeness for South Asia and Middle East regions.

## [1.0.0] - 2025-09-28

### Added
- Initial release of Country Code Max
- Beautiful animated country code picker component
- Theme-aware design that adapts to light and dark themes
- Cross-platform support for web and mobile
- Smart search functionality by country name, code, or dial code
- Favorites system for frequently used countries
- Optional country flags display
- Form validation support with error states
- Responsive design for different screen sizes
- Smooth animations and micro-interactions
- Comprehensive documentation and examples

### Features
- `AnimatedCountryCodePicker` - Main animated picker component
- `CountryCodePicker` - Basic picker component
- `CountryCodePickerModal` - Modal/bottom sheet for country selection
- Support for 100+ countries with dial codes
- Customizable appearance and behavior
- Easy integration with existing Flutter apps
