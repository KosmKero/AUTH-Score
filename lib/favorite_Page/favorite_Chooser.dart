import 'package:flutter/material.dart';

import '../globals.dart';
import 'Basketball_Favorite_Page.dart';
import 'Football_Favorite_Page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ακούει ποιο άθλημα έχει επιλεγεί από το AppBar
    return ValueListenableBuilder<String>(
      valueListenable: selectedSport,
      builder: (context, sport, _) {
        if (sport == 'football') {
          // Φορτώνει τα αγαπημένα του Ποδοσφαίρου
          return const FootballFavoritePage();
        } else {
          // Φορτώνει τα αγαπημένα του Μπάσκετ
          return const BasketballFavoritePage();

        }
      },
    );
  }
}