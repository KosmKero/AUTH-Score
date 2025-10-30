import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

import '../Data_Classes/MatchDetails.dart';

class SlotPickerDialog extends StatefulWidget {
  final MatchDetails match;
  final int phase;
  final int maxSlots;

  const SlotPickerDialog({
    required this.match,
    required this.phase,
    required this.maxSlots,
  });

  @override
  _SlotPickerDialogState createState() => _SlotPickerDialogState();
}

class _SlotPickerDialogState extends State<SlotPickerDialog> {
  late int selectedSlot;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    selectedSlot = widget.match.slot;
  }

  @override
  Widget build(BuildContext context) {
    // κάθε item ~66px (height + margin). Περιορίζουμε συνολικό ύψος dialog.
    final double itemHeight = 66.0;
    final double computedHeight =
    math.min(widget.maxSlots * itemHeight, 380.0); // max 380 px

    return AlertDialog(
      title: Text("Επιλογή θέσης (Φάση των ${widget.phase})"),
      content: SizedBox(
        width: double.maxFinite,
        height: computedHeight,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.maxSlots,
          itemBuilder: (context, index) {
            final isSelected = selectedSlot == index;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: InkWell(
                onTap: () => setState(() => selectedSlot = index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${index+1}",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check, color: Colors.white),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // επιστρέφει null
          child: Text("Ακύρωση"),
        ),
        ElevatedButton(
          onPressed: _saving
              ? null
              : () async {
            setState(() => _saving = true);
            try {
              await FirebaseFirestore.instance
                  .collection("year")
                  .doc(thisYearNow.toString())
                  .collection("matches")
                  .doc(widget.match.matchKey)
                  .set({"slot": selectedSlot}, SetOptions(merge: true));


              // Επιστρέφουμε το νέο slot στον caller
              Navigator.pop(context, selectedSlot);
            } catch (e) {
              setState(() => _saving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Σφάλμα αποθήκευσης: $e")),
              );
            }
          },
          child: _saving
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text("Αποθήκευση"),
        ),
      ],
    );
  }
}
