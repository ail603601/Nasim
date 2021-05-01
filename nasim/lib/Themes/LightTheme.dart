import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme {
  ThemeData get theme => ThemeData(
      // Define the default brightness and colors.
      brightness: Brightness.dark,
      primaryColor: Colors.lightBlue[800],
      accentColor: Colors.cyan[600],
      // backgroundColor: Color(0xFF242634),
      canvasColor: Color(0xFF181818),
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Define the default font family.
      fontFamily: 'Georgia',

      // Define the default TextTheme. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: TextTheme(
        headline1: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.white)),
        headline2: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 60.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline3: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 48.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline4: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 36.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline5: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 24.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline6: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal, color: Colors.white)),
        bodyText1: GoogleFonts.openSans(textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal, color: Colors.white)),
        bodyText2: GoogleFonts.openSans(textStyle: TextStyle(fontSize: 12.0, fontStyle: FontStyle.normal, color: Colors.white)),
      ));
}
