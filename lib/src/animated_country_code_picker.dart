import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/screen_util_helper.dart';
import 'country_code_picker_modal.dart';
import 'models/country_code.dart';
import 'models/country_data.dart';

/// Country code picker with subtle hover/focus/error animations and label.
///
/// Use this when you need a form-friendly input with validation messaging.
class AnimatedCountryCodePicker extends StatefulWidget {
  /// Two-letter ISO code to preselect, e.g. `"NP"`.
  final String? initialCountryCode;

  /// ISO codes to pin at the top of the modal.
  final List<String>? favorites;

  /// Whether to display the search bar in the modal.
  final bool showSearchBar;

  /// Whether to display the dialing code text on the trigger.
  final bool showDialCode;

  /// Whether to show country flags.
  final bool showFlags;

  /// Callback with the selected country.
  final Function(CountryCode)? onCountrySelected;

  /// Optional search hint text for the modal.
  final String? searchHint;

  /// Fixed height of the input.
  final double? height;

  /// Fixed width of the input.
  final double? width;

  /// Optional label rendered above the input.
  final String? label;

  /// Shows a required asterisk next to the label when true.
  final bool isRequired;

  /// Error text shown below the input.
  final String? errorText;

  /// Creates an animated country code picker input.
  const AnimatedCountryCodePicker({
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
    this.label,
    this.isRequired = false,
    this.errorText,
  }) : super(key: key);

  @override
  State<AnimatedCountryCodePicker> createState() =>
      _AnimatedCountryCodePickerState();
}

class _AnimatedCountryCodePickerState extends State<AnimatedCountryCodePicker>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _focusController;
  late AnimationController _errorController;

  late Animation<double> _hoverAnimation;
  late Animation<double> _focusAnimation;
  late Animation<double> _errorAnimation;

  CountryCode? _selectedCountry;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialCountry();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _errorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.elasticOut,
    ));
  }

  void _loadInitialCountry() {
    if (widget.initialCountryCode != null) {
      _selectedCountry = CountryData.countries.firstWhere(
        (country) => country.code == widget.initialCountryCode,
        orElse: () => CountryData.countries.first,
      );
    } else {
      _selectedCountry = CountryData.countries.first;
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  void _showPicker() {
    _focusController.forward();
    _showCountryPickerModal();
  }

  void _hidePicker() {
    _focusController.reverse();
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
          countries: CountryData.countries,
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
            _hidePicker();
          },
          onClose: () {
            Navigator.of(context).pop();
            _hidePicker();
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
          countries: CountryData.countries,
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
            _hidePicker();
          },
          onClose: () {
            Navigator.of(context).pop();
            _hidePicker();
          },
        ),
      );
    }
  }

  void _onHoverEnter() {
    _hoverController.forward();
  }

  void _onHoverExit() {
    _hoverController.reverse();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    if (hasError) {
      _errorController.forward();
    } else {
      _errorController.reverse();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) _buildLabel(),
        _buildPicker(hasError),
        if (hasError) _buildErrorText(),
      ],
    );
  }

  Widget _buildLabel() {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenUtilHelper.safeHeight(context, 8)),
      child: RichText(
        text: TextSpan(
          text: widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: ScreenUtilHelper.safeFontSize(context, 14),
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            if (widget.isRequired)
              TextSpan(
                text: ' *',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: ScreenUtilHelper.safeFontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPicker(bool hasError) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _hoverController,
        _focusController,
        _errorController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value,
          child: GestureDetector(
            onTap: _showPicker,
            onTapDown: (_) => _onFocusChange(true),
            onTapCancel: () => _onFocusChange(false),
            child: MouseRegion(
              onEnter: (_) => _onHoverEnter(),
              onExit: (_) => _onHoverExit(),
              child: Container(
                height:
                    widget.height ?? ScreenUtilHelper.safeHeight(context, 56),
                width: widget.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                      ScreenUtilHelper.safeRadius(context, 12)),
                  border: Border.all(
                    color: _getBorderColor(hasError),
                    width: _getBorderWidth(),
                  ),
                  boxShadow: _getBoxShadow(),
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
            ),
          ),
        );
      },
    );
  }

  Color _getBorderColor(bool hasError) {
    if (hasError) {
      return Theme.of(context).colorScheme.error;
    }
    if (_isFocused) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
  }

  double _getBorderWidth() {
    if (_isFocused) return 2.0;
    return 1.0;
  }

  List<BoxShadow> _getBoxShadow() {
    if (_isFocused) {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  Widget _buildFlag() {
    if (!widget.showFlags) return SizedBox.shrink();

    // Calculate responsive sizes based on widget height
    final containerHeight = widget.height ?? ScreenUtilHelper.safeHeight(context, 56);
    final flagHeight = (containerHeight * 0.43).clamp(20.0, 32.0); // 43% of height, clamped between 20-32
    final flagWidth = flagHeight * 1.33; // Maintain aspect ratio
    final leftMargin = (containerHeight * 0.14).clamp(8.0, 16.0); // 14% of height, clamped between 8-16
    final borderRadius = (containerHeight * 0.07).clamp(2.0, 6.0); // 7% of height, clamped between 2-6

    return Container(
      margin: EdgeInsets.only(left: leftMargin),
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
    final rightMargin = (containerHeight * 0.14).clamp(8.0, 16.0); // 14% of height, clamped between 8-16
    
    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _focusAnimation.value * math.pi,
          child: Container(
            margin: EdgeInsets.only(right: rightMargin),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _isFocused
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
              size: iconSize,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorText() {
    return AnimatedBuilder(
      animation: _errorAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _errorAnimation.value) * -10),
          child: Opacity(
            opacity: _errorAnimation.value.clamp(0.0, 1.0),
            child: Container(
              margin:
                  EdgeInsets.only(top: ScreenUtilHelper.safeHeight(context, 8)),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: ScreenUtilHelper.safeRadius(context, 16),
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(width: ScreenUtilHelper.safeWidth(context, 8)),
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: ScreenUtilHelper.safeFontSize(context, 12),
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
