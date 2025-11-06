import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/screen_util_helper.dart';
import 'models/country_code.dart';

/// Modal UI for browsing and searching countries.
///
/// Used internally by the picker widgets but can be embedded directly.
class CountryCodePickerModal extends StatefulWidget {
  /// Source list of countries to display.
  final List<CountryCode> countries;

  /// ISO codes to pin as favorites at the top.
  final List<String>? favorites;

  /// Whether to show the search bar.
  final bool showSearchBar;

  /// Whether to show country flags.
  final bool showFlags;

  /// Placeholder text for the search input.
  final String? searchHint;

  /// Called when a country is selected.
  final Function(CountryCode) onCountrySelected;

  /// Called when the modal should close.
  final VoidCallback onClose;

  /// Creates a modal used to choose a country.
  const CountryCodePickerModal({
    Key? key,
    required this.countries,
    this.favorites,
    this.showSearchBar = true,
    this.showFlags = true,
    this.searchHint,
    required this.onCountrySelected,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CountryCodePickerModal> createState() => _CountryCodePickerModalState();
}

class _CountryCodePickerModalState extends State<CountryCodePickerModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _searchTextController = TextEditingController();
  List<CountryCode> _filteredCountries = [];
  List<CountryCode> _favoriteCountries = [];
  bool _isSearching = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupCountries();
    _setupSearchListener();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Initialize with default slide animation (will be updated in build)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
  }

  void _setupCountries() {
    _filteredCountries = List.from(widget.countries);

    if (widget.favorites != null && widget.favorites!.isNotEmpty) {
      _favoriteCountries = widget.countries.where((country) {
        return widget.favorites!.contains(country.code);
      }).toList();
    }
  }

  void _setupSearchListener() {
    _searchTextController.addListener(() {
      setState(() {
        _isSearching = _searchTextController.text.isNotEmpty;
        _filterCountries();
      });
    });
  }

  void _filterCountries() {
    final query = _searchTextController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredCountries = List.from(widget.countries);
    } else {
      _filteredCountries = widget.countries.where((country) {
        return country.name.toLowerCase().contains(query) ||
            country.code.toLowerCase().contains(query) ||
            country.dialCode.contains(query);
      }).toList();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _selectCountry(CountryCode country) {
    if (_isDisposed) return;

    // Add selection animation
    _scaleController.forward().then((_) {
      if (!_isDisposed) {
        _scaleController.reverse();
      }
    });

    // Close modal with delay for animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isDisposed) return;

      widget.onCountrySelected(country);
      // Close the modal by reversing animations
      _slideController.reverse();
      _fadeController.reverse();
      _scaleController.reverse();
      // Call onClose after animations complete
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onClose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 768;

    // Update slide animation based on screen size
    _slideAnimation = Tween<Offset>(
      begin: isLargeScreen ? const Offset(0, 0.3) : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideController,
        _fadeController,
        _scaleController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withValues(
                    alpha: (_fadeAnimation.value * 0.5).clamp(0.0, 1.0)),
              ),
            ),

            // Modal Content
            if (isLargeScreen)
              // Center modal for large screens
              Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: math.min(
                            ScreenUtilHelper.safeWidth(context, 500),
                            screenWidth * 0.8),
                        height: math.min(
                            ScreenUtilHelper.safeHeight(context, 600),
                            screenHeight * 0.8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                              ScreenUtilHelper.safeRadius(context, 24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildHeader(),
                            if (widget.showSearchBar) _buildSearchBar(),
                            _buildContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              // Bottom sheet for mobile
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        height: screenHeight * 0.7,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                ScreenUtilHelper.safeRadius(context, 24)),
                            topRight: Radius.circular(
                                ScreenUtilHelper.safeRadius(context, 24)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildHeader(),
                            if (widget.showSearchBar) _buildSearchBar(),
                            _buildContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ScreenUtilHelper.safeWidth(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ScreenUtilHelper.safeRadius(context, 24)),
          topRight: Radius.circular(ScreenUtilHelper.safeRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenUtilHelper.safeWidth(context, 40),
            height: ScreenUtilHelper.safeHeight(context, 4),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(
                  ScreenUtilHelper.safeRadius(context, 2)),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              'Select Country',
              style: GoogleFonts.plusJakartaSans(
                fontSize: ScreenUtilHelper.safeFontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: ScreenUtilHelper.safeWidth(context, 32),
              height: ScreenUtilHelper.safeHeight(context, 32),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    ScreenUtilHelper.safeRadius(context, 16)),
              ),
              child: Icon(
                Icons.close_rounded,
                size: ScreenUtilHelper.safeRadius(context, 18),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ScreenUtilHelper.safeWidth(context, 20)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            BorderRadius.circular(ScreenUtilHelper.safeRadius(context, 12)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchTextController,
        style: GoogleFonts.plusJakartaSans(
          fontSize: ScreenUtilHelper.safeFontSize(context, 16),
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: widget.searchHint ?? 'Search countries...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: ScreenUtilHelper.safeFontSize(context, 16),
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: ScreenUtilHelper.safeRadius(context, 20),
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon: _isSearching
              ? GestureDetector(
                  onTap: () {
                    _searchTextController.clear();
                  },
                  child: Icon(
                    Icons.clear_rounded,
                    size: ScreenUtilHelper.safeRadius(context, 20),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: ScreenUtilHelper.safeWidth(context, 16),
            vertical: ScreenUtilHelper.safeHeight(context, 16),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: ScreenUtilHelper.safeHeight(context, 20)),
        child: Column(
          children: [
            if (_favoriteCountries.isNotEmpty && !_isSearching)
              _buildFavoritesSection(),
            Expanded(
              child: _buildCountriesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtilHelper.safeWidth(context, 20)),
          child: Text(
            'Favorites',
            style: GoogleFonts.plusJakartaSans(
              fontSize: ScreenUtilHelper.safeFontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
        SizedBox(height: ScreenUtilHelper.safeHeight(context, 12)),
        Container(
          height: ScreenUtilHelper.safeHeight(context, 80),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtilHelper.safeWidth(context, 20)),
            itemCount: _favoriteCountries.length,
            itemBuilder: (context, index) {
              final country = _favoriteCountries[index];
              return _buildFavoriteCountryItem(country);
            },
          ),
        ),
        SizedBox(height: ScreenUtilHelper.safeHeight(context, 20)),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ScreenUtilHelper.safeWidth(context, 20)),
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        SizedBox(height: ScreenUtilHelper.safeHeight(context, 20)),
      ],
    );
  }

  Widget _buildFavoriteCountryItem(CountryCode country) {
    return GestureDetector(
      onTap: () => _selectCountry(country),
      child: Container(
        width: ScreenUtilHelper.safeWidth(context, 60),
        margin: EdgeInsets.only(right: ScreenUtilHelper.safeWidth(context, 12)),
        padding: EdgeInsets.all(ScreenUtilHelper.safeWidth(context, 8)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius:
              BorderRadius.circular(ScreenUtilHelper.safeRadius(context, 12)),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showFlags) ...[
              _buildCountryFlag(country,
                  size: ScreenUtilHelper.safeWidth(context, 24)),
              SizedBox(height: ScreenUtilHelper.safeHeight(context, 4)),
            ],
            Text(
              country.code,
              style: GoogleFonts.plusJakartaSans(
                fontSize: ScreenUtilHelper.safeFontSize(context, 10),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              country.dialCode,
              style: GoogleFonts.plusJakartaSans(
                fontSize: ScreenUtilHelper.safeFontSize(context, 8),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountriesList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenUtilHelper.safeWidth(context, 20)),
      itemCount: _filteredCountries.length,
      itemBuilder: (context, index) {
        final country = _filteredCountries[index];
        return _buildCountryItem(country, index);
      },
    );
  }

  Widget _buildCountryItem(CountryCode country, int index) {
    return GestureDetector(
      onTap: () => _selectCountry(country),
      child: Container(
        margin:
            EdgeInsets.only(bottom: ScreenUtilHelper.safeHeight(context, 8)),
        padding: EdgeInsets.symmetric(
            horizontal: ScreenUtilHelper.safeWidth(context, 16),
            vertical: ScreenUtilHelper.safeHeight(context, 12)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              BorderRadius.circular(ScreenUtilHelper.safeRadius(context, 12)),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            if (widget.showFlags) ...[
              _buildCountryFlag(country),
              SizedBox(width: ScreenUtilHelper.safeWidth(context, 12)),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: ScreenUtilHelper.safeFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    country.dialCode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: ScreenUtilHelper.safeFontSize(context, 14),
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              country.code,
              style: GoogleFonts.plusJakartaSans(
                fontSize: ScreenUtilHelper.safeFontSize(context, 12),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryFlag(CountryCode country, {double? size}) {
    final flagSize = size ?? ScreenUtilHelper.safeWidth(context, 32);
    return Container(
      width: flagSize,
      height: flagSize * 0.75,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(ScreenUtilHelper.safeRadius(context, 4)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(ScreenUtilHelper.safeRadius(context, 4)),
        child: country.flag != null
            ? Image.asset(
                country.flag!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultFlag(flagSize),
              )
            : _buildDefaultFlag(flagSize),
      ),
    );
  }

  Widget _buildDefaultFlag(double size) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius:
            BorderRadius.circular(ScreenUtilHelper.safeRadius(context, 4)),
      ),
      child: Icon(
        Icons.flag,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
