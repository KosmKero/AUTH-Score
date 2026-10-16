import 'package:flutter/material.dart';

import 'globals.dart';

class AppTheme {
  // Βασικά χρώματα (Semantic) που μένουν ίδια και στα 2 modes
  static const Color primaryBrand = Color(0xFF2563EB); // Ένα ωραίο, μοντέρνο αθλητικό μπλε
  static const Color liveRed = Color(0xFFE53935);      // Έντονο κόκκινο για τα LIVE σκορ
  static const Color favoriteAmber = Colors.amber;     // Για τα αστεράκια / ειδοποιήσεις

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Arial', // Μπαίνει παντού αυτόματα!
    scaffoldBackgroundColor: lightModeBackGround, // Ξεκούραστο ανοιχτό γκρι
    cardColor: lightModeContainer, // Ολόλευκες κάρτες για να κάνουν αντίθεση
    primaryColor: primaryBrand,
    colorScheme: const ColorScheme.light(
      primary: primaryBrand,
      secondary: liveRed,
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Color(0xFF111827)), // Βασικό κείμενο
      bodySmall: TextStyle(color: Color(0xFF6B7280)),  // Δευτερεύον κείμενο (ώρες, ημερομηνίες)
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(250, 46, 90, 136), // Το χρώμα σου
      foregroundColor: Colors.white, // Χρώμα για εικονίδια και κείμενο (π.χ. 🔍)
      elevation: 0, // Αφαιρεί τη σκιά
    ),

    dividerColor: Colors.grey[300],
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Arial',
    scaffoldBackgroundColor: darkModeBackGround, // Το απόλυτο dark background
    cardColor: darkModeWidgets, // Λίγο πιο ανοιχτό για τις κάρτες
    primaryColor: primaryBrand,
    colorScheme: const ColorScheme.dark(
      primary: primaryBrand,
      secondary: liveRed,
      surface: Color(0xFF1E1E1E),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF9FAFB), fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Color(0xFFF9FAFB)),
      bodySmall: TextStyle(color: Color(0xFF9CA3AF)),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    dividerColor: Colors.grey[800],
  );

// --- ΧΡΩΜΑΤΑ ΓΙΑ ΤΟΥΣ ΠΙΝΑΚΕΣ ΒΑΘΜΟΛΟΓΙΩΝ ---
  // Φόντο για τις ζυγές γραμμές (Ζεβρέ)
  static const Color tableRowLight1 = Color.fromARGB(255, 235, 243, 255); // Ζεβρέ 1 (Light)
  static const Color tableRowLight2 = Colors.white;                       // Ζεβρέ 2 (Light)

  static const Color tableRowDark1 = Color(0xFF2D2D2D);                   // Ζεβρέ 1 (Dark)
  static const Color tableRowDark2 = Color(0xFF1E1E1E);                   // Ζεβρέ 2 (Dark)

  static const Color pointsLight = Color(0xFF1976D2);
  static const Color pointsDark = Colors.lightBlueAccent;

  // Χρώμα Πρόκρισης (π.χ. Πράσινο)
  static const Color promotionGreen = Colors.green;
  static const Color promotionLight = Colors.green;
  static const Color promotionDark = Color(0xFF388E3C);
}