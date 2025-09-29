import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_max/country_code_max.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Country Code Max Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CountryCode? _selectedCountry;
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country Code Max'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number Input',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                SizedBox(
                  width: 120.w,
                  child: AnimatedCountryCodePicker(
                    initialCountryCode: "US",
                    favorites: ["US", "IN", "GB", "CA", "AU"],
                    showSearchBar: true,
                    showFlags: true,
                    searchHint: "Search countries...",
                    onCountrySelected: (country) {
                      setState(() {
                        _selectedCountry = country;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            Text(
              'Without Flags',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            AnimatedCountryCodePicker(
              initialCountryCode: "IN",
              showFlags: false,
              onCountrySelected: (country) {
                print('Selected: ${country.name} (${country.dialCode})');
              },
            ),
            SizedBox(height: 40.h),
            Text(
              'With Validation',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20.h),
            AnimatedCountryCodePicker(
              label: "Country Code",
              isRequired: true,
              errorText: _selectedCountry == null ? "Please select a country" : null,
              onCountrySelected: (country) {
                setState(() {
                  _selectedCountry = country;
                });
              },
            ),
            if (_selectedCountry != null) ...[
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Country:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Name: ${_selectedCountry!.name}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.sp),
                    ),
                    Text(
                      'Code: ${_selectedCountry!.code}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.sp),
                    ),
                    Text(
                      'Dial Code: ${_selectedCountry!.dialCode}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
