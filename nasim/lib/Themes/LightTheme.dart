import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme {
  ThemeData get theme => ThemeData(
      // Define the default brightness and colors.
      // brightness: Brightness.dark,
      brightness: Brightness.light,
      // primaryColor: Colors.lightBlue[800],
      // accentColor: Colors.cyan[600],
      primaryColor: Colors.blue,
      accentColor: Colors.green,
      canvasColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Define the default font family.
      fontFamily: 'Georgia',

      // Define the default TextTheme. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      textTheme: TextTheme(
        headline1: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white)),
        headline2: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 26.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline3: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 24.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline4: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 20.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline5: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 18.0, fontStyle: FontStyle.normal, color: Colors.white)),
        headline6: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 16.0, fontStyle: FontStyle.normal, color: Colors.white)),
        bodyText1: GoogleFonts.openSans(textStyle: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black87)),
        bodyText2: GoogleFonts.openSans(textStyle: TextStyle(fontSize: 12.0, fontStyle: FontStyle.normal, color: Colors.black87)),
      ));
}
