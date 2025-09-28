import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker_plus/country_code_picker_plus.dart';

void main() {
  group('CountryCodePickerPlus', () {
    testWidgets('AnimatedCountryCodePicker renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: AnimatedCountryCodePicker(
                  onCountrySelected: (country) {},
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(AnimatedCountryCodePicker), findsOneWidget);
    });

    testWidgets('CountryCodePicker renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              home: Scaffold(
                body: CountryCodePicker(
                  onCountrySelected: (country) {},
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(CountryCodePicker), findsOneWidget);
    });

    test('CountryCode model works correctly', () {
      final country = CountryCode(
        name: 'United States',
        code: 'US',
        dialCode: '+1',
        flag: 'assets/flags/us.png',
      );

      expect(country.name, 'United States');
      expect(country.code, 'US');
      expect(country.dialCode, '+1');
      expect(country.flag, 'assets/flags/us.png');
    });

    test('CountryData contains countries', () {
      expect(CountryData.countries.isNotEmpty, true);
      expect(CountryData.countries.length, greaterThan(50));
    });
  });
}
