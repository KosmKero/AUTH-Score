import 'package:flutter/material.dart';
import 'package:untitled1/Firebase_Handle/betting_result_update.dart';
import 'package:untitled1/globals.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  bool _isLoading = false; // Μεταβλητή για το Loading State του κουμπιού

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _isLoading
            ? null // Απενεργοποιεί το κουμπί όσο φορτώνει
            : () async {
          // 1. ΕΛΕΓΧΟΣ ΜΕΣΩ ΤΗΣ ΜΝΗΜΗΣ (0 Reads - Αστραπιαίο)
          if (!globalUser.isSuperUser) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Δεν έχεις δικαίωμα για αυτή την ενέργεια.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          setState(() {
            _isLoading = true;
          });

          try {
            // 2. ΕΚΤΕΛΕΣΗ ΤΗΣ ΕΝΗΜΕΡΩΣΗΣ
            await BettingResultUpdate().checkAndUpdateStats();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Τα στατιστικά ενημερώθηκαν επιτυχώς!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print("🚨 ΣΦΑΛΜΑ UPDATE: $e");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Σφάλμα: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          'Update Stats for Finished Matches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}