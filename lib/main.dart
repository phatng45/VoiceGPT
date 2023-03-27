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

  // This widget is the root of your application.
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
