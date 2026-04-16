import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../globals.dart';

class SkeletonKnockouts extends StatelessWidget {
  const SkeletonKnockouts({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = darkModeNotifier.value;
    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 10),
        child: ListView.builder(
          itemCount: 8, // 8 ψεύτικα ματς
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: SizedBox(
                  width: 140, // Ίδιο πλάτος με τις κάρτες σου
                  height: 85, // Ίδιο ύψος με τις κάρτες σου
                  child: Card(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 25, height: 25, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              Container(width: 20, height: 15, color: Colors.white),
                            ],
                          ),
                          const Divider(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 25, height: 25, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              Container(width: 20, height: 15, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}