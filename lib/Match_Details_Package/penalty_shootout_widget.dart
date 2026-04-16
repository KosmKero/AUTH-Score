import 'package:flutter/material.dart';

import '../Data_Classes/MatchDetails.dart';
import '../globals.dart';

class PenaltyShootoutPanel extends StatelessWidget {
  final MatchDetails match; // Παίρνουμε ολόκληρο τον αγώνα

  const PenaltyShootoutPanel({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    // Το ListenableBuilder "ακούει" το match. Όποτε τρέχει το notifyListeners() 
    // στο MatchDetails, ξαναζωγραφίζει ΑΥΤΟ το κομμάτι!
    return ListenableBuilder(
      listenable: match,
      builder: (context, child) {
        final shootout = match.penaltyShootout;
        final bool isDark = darkModeNotifier.value;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Διαδικασία Πέναλτι",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black
                ),
              ),
              const SizedBox(height: 16),

              // Γηπεδούχος ομάδα
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      match.homeTeam.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: shootout.penalties
                          .where((p) => p.isHomeTeam)
                          .map((p) => _PenaltyDot(isScored: p.isScored))
                          .toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Φιλοξενούμενη ομάδα
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      match.awayTeam.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: shootout.penalties
                          .where((p) => !p.isHomeTeam)
                          .map((p) => _PenaltyDot(isScored: p.isScored))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PenaltyDot extends StatelessWidget {
  final bool isScored;

  const _PenaltyDot({required this.isScored});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: isScored ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}