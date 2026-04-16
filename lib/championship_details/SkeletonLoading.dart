import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../globals.dart'; // Για το darkModeNotifier

class SkeletonStandings extends StatelessWidget {
  const SkeletonStandings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = darkModeNotifier.value;
    final screenWidth = MediaQuery.of(context).size.width;

    // Χρώματα για το εφέ (σκούρα για Dark Mode, ανοιχτά για Light)
    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Expanded(
      child: ListView.builder(
        itemCount: 4, // 4 ψεύτικοι όμιλοι
        itemBuilder: (context, index) {
          return Card(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 8),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ψεύτικος Τίτλος Ομίλου
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Επικεφαλίδες Πίνακα
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => Container(
                        width: index == 1 ? 100 : 30, // Πιο πλατύ για την "Ομάδα"
                        height: 15,
                        color: Colors.white,
                      )),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),

                    // 4 Ψεύτικες Γραμμές (Ομάδες)
                    ...List.generate(4, (rowIndex) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Κυκλάκι για τη θέση (#1)
                          Container(width: 25, height: 25, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                          // Κυκλάκι για Logo και Όνομα Ομάδας
                          Row(
                            children: [
                              Container(width: 25, height: 25, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Container(width: 80, height: 15, color: Colors.white),
                            ],
                          ),
                          // Στατιστικά (κουτάκια)
                          Container(width: 20, height: 15, color: Colors.white),
                          Container(width: 20, height: 15, color: Colors.white),
                          Container(width: 20, height: 15, color: Colors.white),
                          Container(width: 20, height: 15, color: Colors.white),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}