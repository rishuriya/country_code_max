import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'country_code_picker_modal.dart';
import 'models/country_code.dart';
import 'models/country_data.dart';
import 'utils/screen_util_helper.dart';

/// Compact country code selector showing a dial code with optional flag.
///
/// Taps open a modal (`CountryCodePickerModal`) to search and pick a country.
class CountryCodePicker extends StatefulWidget {
  /// Two-letter ISO code to preselect, e.g. `"NP"`.
  final String? initialCountryCode;

  /// ISO codes to pin at the top of the modal.
  final List<String>? favorites;

  /// Whether to display the search bar in the modal.
  final bool showSearchBar;

  /// Whether to display the dialing code text in the trigger.
  final bool showDialCode;

  /// Whether to show flags.
  final bool showFlags;

  /// Callback when a country is selected.
  final Function(CountryCode)? onCountrySelected;

  /// Optional search hint text for the modal.
  final String? searchHint;

  /// Fixed height of the tap target.
  final double? height;

  /// Fixed width of the tap target.
  final double? width;

  /// Creates a compact country code picker widget.
  const CountryCodePicker({
    Key? key,
    this.initialCountryCode,
    this.favorites,
    this.showSearchBar = true,
    this.showDialCode = true,
    this.showFlags = true,
    this.onCountrySelected,
    this.searchHint,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  State<CountryCodePicker> createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<CountryCodePicker>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  List<CountryCode> _allCountries = [];
  CountryCode? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCountries();
    _setupSearchListener();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _loadCountries() {
    _allCountries = CountryData.countries;

    if (widget.initialCountryCode != null) {
      _selectedCountry = _allCountries.firstWhere(
        (country) => country.code == widget.initialCountryCode,
        orElse: () => _allCountries.first,
      );
    } else {
      _selectedCountry = _allCountries.first;
    }
  }

  void _setupSearchListener() {
    // Search functionality will be handled by the modal
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _showCountryPickerModal() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 768;

    if (isLargeScreen) {
      // Use overlay for large screens
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => CountryCodePickerModal(
          countries: _allCountries,
          favorites: widget.favorites,
          showSearchBar: widget.showSearchBar,
          showFlags: widget.showFlags,
          searchHint: widget.searchHint,
          onCountrySelected: (country) {
            setState(() {
              _selectedCountry = country;
            });
            widget.onCountrySelected?.call(country);
            Navigator.of(context).pop();
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      );
    } else {
      // Use bottom sheet for mobile
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
        builder: (context) => CountryCodePickerModal(
          countries: _allCountries,
          favorites: widget.favorites,
          showSearchBar: widget.showSearchBar,
          showFlags: widget.showFlags,
          searchHint: widget.searchHint,
          onCountrySelected: (country) {
            setState(() {
              _selectedCountry = country;
            });
            widget.onCountrySelected?.call(country);
            Navigator.of(context).pop();
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showCountryPickerModal();
      },
      child: Container(
        height: widget.height ?? ScreenUtilHelper.safeHeight(context, 56),
        width: widget.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              BorderRadius.circular(ScreenUtilHelper.safeRadius(context, 12)),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFlag(),
            SizedBox(width: (widget.height ?? ScreenUtilHelper.safeHeight(context, 56)) * 0.21), // 21% of height for spacing
            _buildCountryInfo(),
            const Spacer(),
            _buildDropdownIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlag() {
    if (!widget.showFlags) return SizedBox.shrink();

    // Calculate responsive sizes based on widget height
    final containerHeight = widget.height ?? ScreenUtilHelper.safeHeight(context, 56);
    final flagHeight = (containerHeight * 0.43).clamp(20.0, 32.0); // 43% of height, clamped between 20-32
    final flagWidth = flagHeight * 1.33; // Maintain aspect ratio
    final borderRadius = (containerHeight * 0.07).clamp(2.0, 6.0); // 7% of height, clamped between 2-6

    return Container(
      width: flagWidth,
      height: flagHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _selectedCountry?.flag != null
            ? Image.asset(
                _selectedCountry!.flag!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultFlag(flagHeight, borderRadius),
              )
            : _buildDefaultFlag(flagHeight, borderRadius),
      ),
    );
  }

  Widget _buildDefaultFlag([double? height, double? borderRadius]) {
    final containerHeight = widget.height ?? ScreenUtilHelper.safeHeight(context, 56);
    final flagHeight = height ?? (containerHeight * 0.43).clamp(20.0, 32.0);
    final iconSize = (flagHeight * 0.67).clamp(12.0, 20.0); // 67% of flag height
    final radius = borderRadius ?? (containerHeight * 0.07).clamp(2.0, 6.0);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.flag,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildCountryInfo() {
    // Calculate responsive width based on widget width
    final containerWidth = widget.width;
    final baseWidth = containerWidth != null 
        ? (containerWidth * 0.4).clamp(40.0, 80.0) // 40% of container width, clamped between 40-80
        : ScreenUtilHelper.safeWidth(context, 60);
    
    // Calculate responsive font size based on widget height
    final containerHeight = widget.height ?? ScreenUtilHelper.safeHeight(context, 56);
    final fontSize = (containerHeight * 0.25).clamp(12.0, 16.0); // 25% of height, clamped between 12-16
    
    return Container(
      width: baseWidth,
      child: Text(
        _selectedCountry?.dialCode ?? '+1',
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDropdownIcon() {
    // Calculate responsive icon size based on widget height
    final containerHeight = widget.height ?? ScreenUtilHelper.safeHeight(context, 56);
    final iconSize = (containerHeight * 0.36).clamp(16.0, 24.0); // 36% of height, clamped between 16-24
    
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            size: iconSize,
          ),
        );
      },
    );
  }
}
