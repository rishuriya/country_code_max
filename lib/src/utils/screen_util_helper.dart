import 'package:flutter/material.dart';
import 'package:scalex/scalex.dart';

/// Helper class to safely use ScaleX extensions with fallback to MediaQuery.
///
/// This prevents LateInitializationError when ScaleXInit is not used in the app.
/// ScaleX provides the same simple syntax (4.w, 4.h, 4.sp, 4.r) as ScreenUtil
/// but with smarter behavior that works better on desktop and web.
class ScreenUtilHelper {
  /// Safely gets height value, falling back to MediaQuery if ScaleX is not initialized.
  static double safeHeight(BuildContext context, double value) {
    try {
      // Try to use ScaleX extension - will throw if not initialized
      return value.h;
    } catch (e) {
      // ScaleX not initialized, use MediaQuery fallback
      final mediaQuery = MediaQuery.of(context);
      final screenHeight = mediaQuery.size.height;
      // Use a standard design height (e.g., 812 for iPhone) as reference
      return (value / 812) * screenHeight;
    }
  }

  /// Safely gets width value, falling back to MediaQuery if ScaleX is not initialized.
  static double safeWidth(BuildContext context, double value) {
    try {
      // Try to use ScaleX extension - will throw if not initialized
      return value.w;
    } catch (e) {
      // ScaleX not initialized, use MediaQuery fallback
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      // Use a standard design width (e.g., 375 for iPhone) as reference
      return (value / 375) * screenWidth;
    }
  }

  /// Safely gets radius value, falling back to MediaQuery if ScaleX is not initialized.
  static double safeRadius(BuildContext context, double value) {
    try {
      // Try to use ScaleX extension - will throw if not initialized
      return value.r;
    } catch (e) {
      // ScaleX not initialized, use MediaQuery fallback
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      // Use a standard design width as reference for radius
      return (value / 375) * screenWidth;
    }
  }

  /// Safely gets font size value, falling back to MediaQuery if ScaleX is not initialized.
  static double safeFontSize(BuildContext context, double value) {
    try {
      // Try to use ScaleX extension - will throw if not initialized
      return value.sp;
    } catch (e) {
      // ScaleX not initialized, use MediaQuery fallback
      final mediaQuery = MediaQuery.of(context);
      final textScaler = mediaQuery.textScaler.scale(1.0);
      final screenWidth = mediaQuery.size.width;
      // Use a standard design width as reference for font size
      return ((value / 375) * screenWidth) / textScaler;
    }
  }
}
