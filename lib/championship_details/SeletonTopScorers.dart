import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../globals.dart';

class SkeletonTopPlayers extends StatelessWidget {
  const SkeletonTopPlayers({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = darkModeNotifier.value;
    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: ListView.builder(
          itemCount: 10, // 10 ψεύτικοι παίκτες φτάνουν για να γεμίσουν την οθόνη
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rank & Logo
                    Row(
                      children: [
                        Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                        const SizedBox(width: 8),
                        Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                      ],
                    ),
                    // Player Name & Position
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 120, height: 14, color: Colors.white),
                            const SizedBox(height: 6),
                            Container(width: 80, height: 10, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    // Goals
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}