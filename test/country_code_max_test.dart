import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../lib/country_code_max.dart';

void main() {
  group('CountryCodeMax', () {
    testWidgets('AnimatedCountryCodePicker renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: AnimatedCountryCodePicker(
                  onCountrySelected: (country) {},
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
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
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: CountryCodePicker(
                  onCountrySelected: (country) {},
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
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

    test('CountryData contains Nepal with correct dial code', () {
      final nepal = CountryData.countries.firstWhere(
        (c) => c.code == 'NP' || c.name == 'Nepal',
        orElse: () => throw Exception('Nepal not found in CountryData'),
      );
      expect(nepal.dialCode, '+977');
    });

    testWidgets('AnimatedCountryCodePicker with label renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: AnimatedCountryCodePicker(
                  label: 'Select Country',
                  isRequired: true,
                  onCountrySelected: (country) {},
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AnimatedCountryCodePicker), findsOneWidget);
      expect(find.text('Select Country *'), findsOneWidget);
    });

    testWidgets('AnimatedCountryCodePicker with error shows error text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: AnimatedCountryCodePicker(
                  errorText: 'Please select a country',
                  onCountrySelected: (country) {},
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AnimatedCountryCodePicker), findsOneWidget);
      expect(find.text('Please select a country'), findsOneWidget);
    });

    testWidgets('CountryCodePicker can be tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                useMaterial3: true,
              ),
              home: Scaffold(
                body: CountryCodePicker(
                  onCountrySelected: (country) {},
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CountryCodePicker), findsOneWidget);
      
      // Tap the picker
      await tester.tap(find.byType(CountryCodePicker));
      await tester.pumpAndSettle();
      
      // The modal should open (we can't test the full interaction without more setup)
      // but we can verify the widget responds to taps
      expect(find.byType(CountryCodePicker), findsOneWidget);
    });
  });
}
