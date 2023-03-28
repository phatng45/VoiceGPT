import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voicegpt/app_translation.dart';

import 'HomePage/chat_page_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData lightTheme = ThemeData(
      fontFamily: GoogleFonts.nunito().fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: Colors.orange,
      colorScheme: const ColorScheme(
        primary: Colors.orange,
        brightness: Brightness.light,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.red,
        background: Colors.white,
        onBackground: Colors.white,
        surface: Colors.white,
        onSurface: Colors.white,
      )
  );

  static ThemeData darkTheme = ThemeData(
      fontFamily: GoogleFonts.nunito().fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: Colors.orange,
      colorScheme: const ColorScheme(
        primary: Colors.orange,
        brightness: Brightness.dark,
        onPrimary: Colors.black,
        secondary: Colors.black,
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.red,
        background: Colors.black,
        onBackground: Colors.black,
        surface: Colors.black,
        onSurface: Colors.black,
      )
  );

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.nunito().fontFamily,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
        ).copyWith(secondary: const Color(0xFFFEF9EB)),
      ),
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
      translations: AppTranslation(),
      fallbackLocale: const Locale('en', 'US'),
      locale: Get.deviceLocale ?? const Locale('en', 'US'),
    );
  }
}
