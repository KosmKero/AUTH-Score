import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Firebase_Handle/betting_result_update.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
          onPressed: () async {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .get();

            // Ελέγχει αν ο χρήστης είναι superuser
            if (userDoc.exists && userDoc.data()?['superuser'] == "super123user") {
              // Αν ο χρήστης είναι superuser, καλεί την λειτουργία για την ενημέρωση των στατιστικών
              await BettingResultUpdate().checkAndUpdateStats();

              // Εμφανίζει μήνυμα στον χρήστη ότι τα στατιστικά ενημερώθηκαν
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Stats updated for all finished matches!')),
              );
            } else {
              // Αν ο χρήστης δεν είναι superuser
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You do not have permission to update stats.')),
              );
            }

          },
          child: Text('Update Stats for Finished Matches'),
        ),
    );
  }
}