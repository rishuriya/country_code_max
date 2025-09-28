import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'country_code_picker.dart';
import 'country_code_picker_modal.dart';
import 'models/country_code.dart';
import 'models/country_data.dart';

class AnimatedCountryCodePicker extends StatefulWidget {
  final String? initialCountryCode;
  final List<String>? favorites;
  final bool showSearchBar;
  final bool showDialCode;
  final bool showFlags;
  final Function(CountryCode)? onCountrySelected;
  final String? searchHint;
  final double? height;
  final double? width;
  final String? label;
  final bool isRequired;
  final String? errorText;

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
  State<AnimatedCountryCodePicker> createState() => _AnimatedCountryCodePickerState();
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
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          text: widget.label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            if (widget.isRequired)
              TextSpan(
                text: ' *',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
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
                height: widget.height ?? 56.h,
                width: widget.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _getBorderColor(hasError),
                    width: _getBorderWidth(),
                  ),
                  boxShadow: _getBoxShadow(),
                ),
                child: Row(
                  children: [
                    _buildFlag(),
                    SizedBox(width: 12.w),
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
    return Theme.of(context).colorScheme.outline.withOpacity(0.2);
  }

  double _getBorderWidth() {
    if (_isFocused) return 2.0;
    return 1.0;
  }

  List<BoxShadow> _getBoxShadow() {
    if (_isFocused) {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  Widget _buildFlag() {
    if (!widget.showFlags) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.only(left: 16.w),
      width: 32.w,
      height: 24.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
      animation: _focusController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _focusAnimation.value * math.pi,
          child: Container(
            margin: EdgeInsets.only(right: 16.w),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _isFocused
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 20.r,
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
            opacity: _errorAnimation.value,
            child: Container(
              margin: EdgeInsets.only(top: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 16.r,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.errorText!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
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
