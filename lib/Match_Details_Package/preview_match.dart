import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import '../Data_Classes/match_facts.dart';
import '../globals.dart';

// --- ENUM ΓΙΑ ΤΑ ΘΕΜΑΤΑ ---
enum GraphicTheme {
  emeraldPitch, // Σκούρο Πράσινο + Νέον
  darkCarbon,   // Μαύρο + Λευκό
  premiumGold   // Μαύρο + Χρυσό
}

class StoryPreviewScreen extends StatefulWidget {
  final MatchDetails match;

  const StoryPreviewScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<StoryPreviewScreen> createState() => _StoryPreviewScreenState();
}

class _StoryPreviewScreenState extends State<StoryPreviewScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  bool isSharing = false;
  bool isSquare = false; // true = 1:1 Post, false = 9:16 Story
  GraphicTheme currentTheme = GraphicTheme.emeraldPitch;

  List<String> _getScorers(bool isHome) {
    List<String> scorers = [];
    for (var half in widget.match.matchFact.values) {
      for (var fact in half) {
        if (fact is Goal && fact.isHomeTeam == isHome) {
          scorers.add("${fact.name} ${fact.timeString}'");
        }
      }
    }
    return scorers;
  }

  Future<void> _shareGraphic() async {
    setState(() => isSharing = true);
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 150),
      );

      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/match_result_graphic.png').create();
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: greek ? 'Δείτε το τελικό αποτέλεσμα!' : 'Full Time Result!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Σφάλμα: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> homeScorers = _getScorers(true);
    List<String> awayScorers = _getScorers(false);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(greek ? "Προεπισκόπηση Γραφικού" : "Graphic Preview", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Το preview του Γραφικού
          Expanded(
            child: Center(
              // Εδώ ρυθμίζουμε το Preview για να μην κόβεται
              child: AspectRatio(
                aspectRatio: isSquare ? 1.0 : (9 / 16),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Screenshot(
                    controller: screenshotController,
                    child: _buildGraphic(homeScorers, awayScorers),
                  ),
                ),
              ),
            ),
          ),

          // --- SETTINGS PANEL ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Διακόπτες για Story (9:16) ή Post (1:1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFormatButton("Story (9:16)", Icons.smartphone, !isSquare, () {
                        setState(() => isSquare = false);
                      }),
                      const SizedBox(width: 15),
                      _buildFormatButton("Post (1:1)", Icons.grid_on, isSquare, () {
                        setState(() => isSquare = true);
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Επιλογή Χρωμάτων (Themes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeCircle(GraphicTheme.emeraldPitch, const Color(0xFF1A4A2E), const Color(0xFF00FFA3)),
                      _buildThemeCircle(GraphicTheme.darkCarbon, const Color(0xFF1A1C1E), Colors.white),
                      _buildThemeCircle(GraphicTheme.premiumGold, const Color(0xFF111111), const Color(0xFFFFD700)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Κουμπί Κοινοποίησης
                  isSharing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.share, color: Colors.black),
                      label: Text(
                        greek ? "Κοινοποίηση στο IG" : "Share to IG",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _shareGraphic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ΕΠΙΛΟΓΩΝ (SETTINGS) ---
  Widget _buildFormatButton(String text, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white : Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white54),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: isSelected ? Colors.black : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCircle(GraphicTheme theme, Color color, Color border) {
    bool isSelected = currentTheme == theme;
    return InkWell(
      onTap: () => setState(() => currentTheme = theme),
      child: Container(
        height: 45, width: 45,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: isSelected ? 3.0 : 1.0),
          boxShadow: isSelected ? [BoxShadow(color: border.withOpacity(0.5), blurRadius: 10)] : [],
        ),
        child: isSelected ? Icon(Icons.check, color: border, size: 22) : null,
      ),
    );
  }

  // --- ΤΟ ΚΥΡΙΩΣ ΓΡΑΦΙΚΟ ΠΟΥ ΚΑΝΟΥΜΕ SCREENSHOT ---
  Widget _buildGraphic(List<String> homeScorers, List<String> awayScorers) {
    double width = 1080;
    double height = isSquare ? 1080 : 1920;

    // ΧΡΩΜΑΤΑ ΑΝΑΛΟΓΑ ΜΕ ΤΟ ΘΕΜΑ
    Color bgDark, gradientStart, gradientEnd, textMain, textSecondary, accentColor, boarderColor;

    switch (currentTheme) {
      case GraphicTheme.emeraldPitch:
        bgDark = const Color(0xFF061A0C);
        gradientStart = const Color(0xFF185A32);
        gradientEnd = const Color(0xFF092613);
        textMain = Colors.white;
        textSecondary = Colors.white.withOpacity(0.6);
        accentColor = const Color(0xFF00FFA3);
        boarderColor = Colors.white.withOpacity(0.12);
        break;
      case GraphicTheme.darkCarbon:
        bgDark = const Color(0xFF050505);
        gradientStart = const Color(0xFF1A1C1E);
        gradientEnd = const Color(0xFF111213);
        textMain = Colors.white;
        textSecondary = Colors.white.withOpacity(0.6);
        accentColor = Colors.white;
        boarderColor = Colors.white.withOpacity(0.08);
        break;
      case GraphicTheme.premiumGold:
        bgDark = const Color(0xFF050505);
        gradientStart = const Color(0xFF1F1C18);
        gradientEnd = const Color(0xFF0A0A0A);
        textMain = Colors.white;
        textSecondary = Colors.white.withOpacity(0.6);
        accentColor = const Color(0xFFFFD700);
        boarderColor = const Color(0xFFFFD700).withOpacity(0.3);
        break;
    }

    int homeScoreTotal = widget.match.homeScore + widget.match.penaltyScoreHome;
    int awayScoreTotal = widget.match.awayScore + widget.match.penaltyScoreAway;

    // Scale Factors: Στο 1:1 μικραίνουμε τα πάντα για να χωρέσουν (font sizes, paddings)
    double s = isSquare ? 1.8 : 3.0; // Οριζόντιο/Γενικό Scale
    double v = isSquare ? 1.2 : 3.0; // Κάθετο Scale (Συμπιέζει τα κενά στο τετράγωνο)

    return Container(
      width: width,
      height: height,
      color: bgDark,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isSquare ? 40.0 : 20.0), // Περιθώριο γύρω από την κάρτα
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientStart, gradientEnd],
              ),
              borderRadius: BorderRadius.circular(24 * s),
              border: Border.all(color: boarderColor, width: 2.0),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 40 * s, offset: Offset(0, 15 * v))
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0 * s, vertical: 25.0 * v),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Σημαντικό για να μην κάνει overflow!
                children: [

                  // --- HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "AUTH LEAGUE",
                                style: TextStyle(color: textMain, fontSize: 18 * s, fontWeight: FontWeight.w900, letterSpacing: 1.5 * s)
                            ),
                            SizedBox(height: 4 * v),
                            Text(
                                widget.match.matchweekInfo().toUpperCase(),
                                style: TextStyle(color: textSecondary, fontSize: 11 * s, fontWeight: FontWeight.bold, letterSpacing: 1 * s)
                            ),
                          ],
                        ),
                      ),
                      // Ταμπελάκι FULL TIME
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10 * s),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          "FULL TIME",
                          style: TextStyle(color: accentColor, fontSize: 11 * s, fontWeight: FontWeight.w900, letterSpacing: 1 * s),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isSquare ? 20 * v : 80 * v), // Δυναμικό κενό

                  // --- ΚΥΡΙΩΣ ΣΚΟΡ & ΟΜΑΔΕΣ ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Γηπεδούχος
                      Expanded(
                        child: Column(
                          children: [
                            _buildLogo(widget.match.homeTeam.image, boarderColor, s),
                            SizedBox(height: 14 * v),
                            Text(
                              widget.match.homeTeam.displayName.toUpperCase(),
                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textMain, fontSize: 13 * s, fontWeight: FontWeight.w900, height: 1.2),
                            ),
                          ],
                        ),
                      ),

                      // Σκορ
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0 * s),
                        child: Text(
                          "$homeScoreTotal - $awayScoreTotal",
                          style: TextStyle(color: textMain, fontSize: 52 * s, fontWeight: FontWeight.w900, letterSpacing: -2 * s),
                        ),
                      ),

                      // Φιλοξενούμενος
                      Expanded(
                        child: Column(
                          children: [
                            _buildLogo(widget.match.awayTeam.image, boarderColor, s),
                            SizedBox(height: 14 * v),
                            Text(
                              widget.match.awayTeam.displayName.toUpperCase(),
                              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textMain, fontSize: 13 * s, fontWeight: FontWeight.w900, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (widget.match.isShootoutOver) ...[
                    SizedBox(height: 15 * v),
                    Text(greek ? "ΝΙΚΗ ΣΤΑ ΠΕΝΑΛΤΙ" : "WON ON PENALTIES", style: TextStyle(color: accentColor, fontSize: 11 * s, fontWeight: FontWeight.bold, letterSpacing: 1 * s)),
                  ],

                  SizedBox(height: isSquare ? 20 * v : 80 * v),

                  // --- ΔΙΑΧΩΡΙΣΤΙΚΗ ΓΡΑΜΜΗ & ΣΚΟΡΕΡΣ ---
                  if (homeScorers.isNotEmpty || awayScorers.isNotEmpty) ...[
                    Container(height: 2, width: double.infinity, color: boarderColor),
                    SizedBox(height: 20 * v),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: homeScorers.map((st) => Padding(
                              padding: EdgeInsets.only(bottom: 6.0 * v),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("⚽ ", style: TextStyle(color: textMain.withOpacity(0.3), fontSize: 10 * s)),
                                  Expanded(child: Text(st, style: TextStyle(color: textMain.withOpacity(0.9), fontSize: 12 * s, fontWeight: FontWeight.w600))),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                        SizedBox(width: 15 * s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: awayScorers.map((st) => Padding(
                              padding: EdgeInsets.only(bottom: 6.0 * v),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(st, textAlign: TextAlign.right, style: TextStyle(color: textMain.withOpacity(0.9), fontSize: 12 * s, fontWeight: FontWeight.w600))),
                                  Text(" ⚽", style: TextStyle(color: textMain.withOpacity(0.3), fontSize: 10 * s)),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (!isSquare) Spacer(), // Σπρώχνει το footer κάτω μόνο στο Story

                  // --- FOOTER (Αν είναι 1:1 (Post), ΜΗΝ το εμφανίσεις!) ---
                  if (!isSquare) ...[
                    Text(
                        greek ? "ΑΠΟΤΕΛΕΣΜΑΤΑ & ΣΤΑΤΙΣΤΙΚΑ ΣΤΟ APP" : "RESULTS & STATS IN THE APP",
                        style: TextStyle(color: textSecondary, fontSize: 9 * s, fontWeight: FontWeight.w800, letterSpacing: 1 * s)
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Widget image, Color boarderColor, double s) {
    return Container(
      height: 75 * s, width: 75 * s,
      decoration: BoxDecoration(
        color: boarderColor.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: boarderColor, width: 2.0 * s),
      ),
      child: ClipOval(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: EdgeInsets.all(4.0 * s),
            child: image,
          ),
        ),
      ),
    );
  }
}