import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Lucerna/carbon_footprint.dart';
import 'package:Lucerna/chat.dart';
import 'package:Lucerna/dashboard.dart';
import 'package:Lucerna/journey_record.dart';
import 'package:Lucerna/lamp_stat.dart';
import 'package:Lucerna/login_page.dart';
//import 'package:Lucerna/login_page.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'history_provider.dart'; // Import the provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChangeNotifierProvider(
    create: (context) => HistoryProvider()..loadHistory(), // Load on startup
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucerna',
      theme: appTheme,
      home: LoginPage(),
    );
  }
}

ThemeData appTheme = ThemeData(
  useMaterial3: false,

  // Define the default brightness and colors.
  colorScheme: const ColorScheme(
    primary: Color.fromRGBO(92, 128, 1, 1),
    onPrimary: Colors.white,
    secondary: Color.fromRGBO(124, 181, 24, 1),
    onSecondary: Colors.white,
    tertiary: Color.fromRGBO(251, 97, 7, 1),
    onTertiary: Colors.white,
    surface: Color.fromRGBO(251, 176, 45, 1),
    onSurface: Colors.white,
    surfaceBright: Color.fromRGBO(243, 222, 44, 1),
    error: Colors.redAccent,
    onError: Colors.white,
    brightness: Brightness.light,
  ),

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  textTheme: TextTheme(
    // text styling for page title
    headlineLarge: GoogleFonts.ptSansCaption(
      fontSize: 35,
      fontWeight: FontWeight.bold,
      //height: 35,
      letterSpacing: 3.5,
    ),

    headlineMedium: GoogleFonts.ptSansCaption(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      //height: 35,
      letterSpacing: 3.5,
    ),

    // text styling for button
    displayLarge: GoogleFonts.ptSansCaption(
      fontSize: 17.5,
      fontWeight: FontWeight.bold,
    ),

    // text styling for text title
    titleLarge: GoogleFonts.ptSerif(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),

    titleSmall: GoogleFonts.ptSerif(
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),

    bodyLarge: GoogleFonts.ptSans(
      fontSize: 15,
    ),

    bodyMedium: GoogleFonts.ptSansNarrow(
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),

    bodySmall: GoogleFonts.ptSans(
      fontSize: 12.5,
    ),

    // TextField in Carbon Footprint Form
    labelSmall: GoogleFonts.ptSans(
      fontSize: 15,
      color: Color.fromRGBO(0, 0, 0, 0.5),
    ),
  ),
);
