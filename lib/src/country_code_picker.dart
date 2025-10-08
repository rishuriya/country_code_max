import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'country_code_picker_modal.dart';
import 'models/country_code.dart';
import 'models/country_data.dart';

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
        height: widget.height ?? 56.h,
        width: widget.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildFlag(),
            SizedBox(width: 8.w),
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
    
    return Container(
      width: 32.w,
      height: 24.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: _selectedCountry?.flag != null
            ? Image.asset(
                _selectedCountry!.flag!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultFlag(),
              )
            : _buildDefaultFlag(),
      ),
    );
  }

  Widget _buildDefaultFlag() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Icon(
        Icons.flag,
        size: 16.r,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildCountryInfo() {
    return Container(
      width: 60.w,
      child: Text(
        _selectedCountry?.dialCode ?? '+1',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDropdownIcon() {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20.r,
          ),
        );
      },
    );
  }
}
