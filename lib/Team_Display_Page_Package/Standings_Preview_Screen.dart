import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../Data_Classes/Team.dart';
import '../globals.dart';

// --- ENUM ΓΙΑ ΤΑ 5 ΘΕΜΑΤΑ ---
enum GraphicTheme {
  emeraldPitch, // Σκούρο Πράσινο + Νέον (1 - Dark)
  darkCarbon,   // Μαύρο + Λευκό (2 - Dark)
  royalBlue,    // Σκούρο Μπλε + Γαλάζιο/Λευκό (3 - Dark)
  cleanLight,   // Λευκό + Μπλε (4 - Light!)
  sportsWhite   // Λευκό + Κόκκινο (5 - Light!)
}

class StandingsStoryPreviewScreen extends StatefulWidget {
  final int group;
  final List<Team> teams;

  const StandingsStoryPreviewScreen({Key? key, required this.group, required this.teams}) : super(key: key);

  @override
  State<StandingsStoryPreviewScreen> createState() => _StandingsStoryPreviewScreenState();
}

class _StandingsStoryPreviewScreenState extends State<StandingsStoryPreviewScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  bool isSharing = false;
  bool isSquare = false; // true = 1:1 Post, false = 9:16 Story
  GraphicTheme currentTheme = GraphicTheme.emeraldPitch;

  Future<void> _shareGraphic() async {
    setState(() => isSharing = true);
    try {
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 150),
      );

      if (imageBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File('${directory.path}/standings_graphic.png').create();
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: greek ? 'Η βαθμολογία του Ομίλου ${widget.group}!' : 'Group ${widget.group} Standings!',
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
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Screenshot(
                    controller: screenshotController,
                    child: _buildGraphic(),
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

                  // --- ΕΠΙΛΟΓΗ ΧΡΩΜΑΤΩΝ (5 ΘΕΜΑΤΑ - 3 Dark, 2 Light) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeCircle(GraphicTheme.emeraldPitch, const Color(0xFF1A4A2E), const Color(0xFF00FFA3)),
                      _buildThemeCircle(GraphicTheme.darkCarbon, const Color(0xFF1A1C1E), Colors.white),
                      _buildThemeCircle(GraphicTheme.royalBlue, const Color(0xFF0B1B3D), const Color(0xFF3388FF)),
                      _buildThemeCircle(GraphicTheme.cleanLight, const Color(0xFFF0F2F5), const Color(0xFF1D4ED8)), // Light + Μπλε
                      _buildThemeCircle(GraphicTheme.sportsWhite, Colors.white, const Color(0xFFE11D48)), // Light + Κόκκινο
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
        height: 42, width: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: isSelected ? 3.0 : 1.0),
          boxShadow: isSelected ? [BoxShadow(color: border.withOpacity(0.5), blurRadius: 10)] : [],
        ),
        child: isSelected ? Icon(Icons.check, color: border, size: 20) : null,
      ),
    );
  }

  // --- ΤΟ ΚΥΡΙΩΣ ΓΡΑΦΙΚΟ ΠΟΥ ΚΑΝΟΥΜΕ SCREENSHOT ---
  Widget _buildGraphic() {
    double width = 1080;
    double height = isSquare ? 1080 : 1920;

    // ΧΡΩΜΑΤΑ ΑΝΑΛΟΓΑ ΜΕ ΤΟ ΘΕΜΑ
    Color bgStory, gradientStart, gradientEnd, textMain, textSecondary, accentColor, boarderColor;
    bool isLightMode = false;

    switch (currentTheme) {
      case GraphicTheme.emeraldPitch:
        bgStory = const Color(0xFF061A0C);
        gradientStart = const Color(0xFF185A32);
        gradientEnd = const Color(0xFF092613);
        textMain = Colors.white;
        textSecondary = Colors.white.withOpacity(0.6);
        accentColor = const Color(0xFF00FFA3);
        boarderColor = Colors.white.withOpacity(0.12);
        break;
      case GraphicTheme.darkCarbon:
        bgStory = const Color(0xFF050505);
        gradientStart = const Color(0xFF1A1C1E);
        gradientEnd = const Color(0xFF111213);
        textMain = Colors.white;
        textSecondary = Colors.white.withOpacity(0.6);
        accentColor = Colors.white;
        boarderColor = Colors.white.withOpacity(0.08);
        break;
      case GraphicTheme.royalBlue:
        bgStory = const Color(0xFF030712);
        gradientStart = const Color(0xFF0F2B5B);
        gradientEnd = const Color(0xFF051024);
        textMain = Colors.white;
        textSecondary = Colors.white.withOpacity(0.6);
        accentColor = const Color(0xFF4DA6FF);
        boarderColor = const Color(0xFF4DA6FF).withOpacity(0.3);
        break;
      case GraphicTheme.cleanLight: // 4. LIGHT + ΜΠΛΕ
        isLightMode = true;
        bgStory = const Color(0xFFE2E8F0); // Απαλό γκρι πίσω από την κάρτα
        gradientStart = Colors.white;
        gradientEnd = const Color(0xFFF8FAFC);
        textMain = const Color(0xFF0F172A); // Πολύ σκούρο μπλε/μαύρο (Slate 900)
        textSecondary = const Color(0xFF64748B); // Slate 500
        accentColor = const Color(0xFF1D4ED8); // Blue 700 (AUTH Blue)
        boarderColor = Colors.black.withOpacity(0.08);
        break;
      case GraphicTheme.sportsWhite: // 5. LIGHT + ΚΟΚΚΙΝΟ
        isLightMode = true;
        bgStory = const Color(0xFFF3F4F6); // Απαλό γκρι (Gray 100)
        gradientStart = Colors.white;
        gradientEnd = const Color(0xFFF9FAFB);
        textMain = const Color(0xFF111827); // Gray 900
        textSecondary = const Color(0xFF6B7280); // Gray 500
        accentColor = const Color(0xFFE11D48); // Rose 600
        boarderColor = Colors.black.withOpacity(0.08);
        break;
    }

    // Παίρνουμε ΜΕΧΡΙ 8 ομάδες.
    List<Team> displayTeams = widget.teams.take(8).toList();

    // Scale Factors
    double s = isSquare ? 1.7 : 2.4;
    double v = isSquare ? 1.0 : 3.0;

    return Container(
      width: width,
      height: height,
      color: bgStory,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(isSquare ? 15.0 : 10.0),
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
                BoxShadow(
                    color: isLightMode ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.4),
                    blurRadius: 40 * s,
                    offset: Offset(0, 15 * v)
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0 * s, vertical: 25.0 * v),
              child: Column(
                children: [

                  // --- HEADER ---
                  Text(
                      "AUTH LEAGUE",
                      style: TextStyle(color: textMain, fontSize: 24 * s, fontWeight: FontWeight.w900, letterSpacing: 2 * s)
                  ),
                  SizedBox(height: 8 * v),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * v),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20 * s),
                      border: Border.all(color: accentColor.withOpacity(0.25)),
                    ),
                    child: Text(
                      greek ? "ΒΑΘΜΟΛΟΓΙΑ • ΟΜΙΛΟΣ ${widget.group}" : "STANDINGS • GROUP ${widget.group}",
                      style: TextStyle(color: accentColor, fontSize: 12 * s, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                  ),

                  Spacer(flex: 1),

                  // --- ΠΙΝΑΚΑΣ HEADER ---
                  Row(
                    children: [
                      SizedBox(width: 45 * s),
                      Expanded(child: Text(greek ? "ΟΜΑΔΑ" : "TEAM", style: TextStyle(color: textSecondary, fontSize: 12 * s, fontWeight: FontWeight.bold))),
                      SizedBox(width: 35 * s, child: Center(child: Text(greek ? "ΑΓ" : "P", style: TextStyle(color: textSecondary, fontSize: 12 * s, fontWeight: FontWeight.bold)))),
                      SizedBox(width: 35 * s, child: Center(child: Text(greek ? "ΔΓ" : "GD", style: TextStyle(color: textSecondary, fontSize: 12 * s, fontWeight: FontWeight.bold)))),
                      SizedBox(width: 45 * s, child: Center(child: Text(greek ? "ΒΑΘ" : "PTS", style: TextStyle(color: textSecondary, fontSize: 12 * s, fontWeight: FontWeight.bold)))),
                    ],
                  ),
                  SizedBox(height: 10 * v),
                  Container(height: 2, color: boarderColor),
                  SizedBox(height: 10 * v),

                  // --- ΟΜΑΔΕΣ (ROWS) ---
                  Expanded(
                    flex: isSquare ? 20 : 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(displayTeams.length, (index) {
                        Team team = displayTeams[index];
                        bool isPromotionSpot = index < 4;

                        return Row(
                          children: [
                            // 1. ΘΕΣΗ (#)
                            SizedBox(
                              width: 30 * s,
                              child: isPromotionSpot
                                  ? Container(
                                width: 22 * s, height: 22 * s,
                                decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                    boxShadow: isLightMode
                                        ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                                        : [BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 8)]
                                ),
                                child: Center(child: Text("${index + 1}", style: TextStyle(color: isLightMode ? Colors.white : Colors.black, fontSize: 12 * s, fontWeight: FontWeight.w900))),
                              )
                                  : Center(child: Text("${index + 1}", style: TextStyle(color: textSecondary, fontSize: 14 * s, fontWeight: FontWeight.bold))),
                            ),
                            SizedBox(width: 10 * s),

                            // 2. ΛΟΓΟΤΥΠΟ
                            _buildLogo(team.image, boarderColor, isLightMode, s),
                            SizedBox(width: 15 * s),

                            // 3. ΟΝΟΜΑ
                            Expanded(
                              child: Text(
                                greek ? team.displayGreek : team.displayEnglish,
                                style: TextStyle(color: textMain, fontSize: 16 * s, fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // 4. ΣΤΑΤΙΣΤΙΚΑ
                            SizedBox(width: 35 * s, child: Center(child: Text("${team.totalGames}", style: TextStyle(color: isLightMode ? textMain.withOpacity(0.7) : textMain.withOpacity(0.9), fontSize: 15 * s, fontWeight: FontWeight.w600)))),
                            SizedBox(width: 35 * s, child: Center(child: Text("${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}", style: TextStyle(color: isLightMode ? textMain.withOpacity(0.7) : textMain.withOpacity(0.9), fontSize: 15 * s, fontWeight: FontWeight.w600)))),

                            // 5. ΠΟΝΤΟΙ
                            SizedBox(
                                width: 45 * s,
                                child: Center(
                                    child: Text("${team.totalPoints}", style: TextStyle(color: textMain, fontSize: 20 * s, fontWeight: FontWeight.w900))
                                )
                            ),
                          ],
                        );
                      }),
                    ),
                  ),

                  // --- FOOTER (ΕΜΦΑΝΙΖΕΤΑΙ ΜΟΝΟ ΣΤΟ STORY 9:16) ---
                  if (!isSquare) ...[
                    Spacer(flex: 1),
                    Container(height: 2, color: boarderColor),
                    SizedBox(height: 10 * v),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 8 * s, height: 8 * s, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                        SizedBox(width: 8 * s),
                        Text(
                          greek ? "ΟΙ 4 ΠΡΩΤΟΙ ΠΡΟΚΡΙΝΟΝΤΑΙ" : "TOP 4 ADVANCE",
                          style: TextStyle(color: textSecondary, fontSize: 11 * s, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * v),

                    // APP BRANDING
                    Text(
                      greek ? "POWERED BY AUTH LEAGUE APP" : "POWERED BY AUTH LEAGUE APP",
                      style: TextStyle(color: isLightMode ? textSecondary.withOpacity(0.5) : accentColor.withOpacity(0.7), fontSize: 9 * s, fontWeight: FontWeight.w900, letterSpacing: 1.5 * s),
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

  Widget _buildLogo(Widget image, Color boarderColor, bool isLightMode, double s) {
    return Container(
      height: 35 * s, width: 35 * s,
      decoration: BoxDecoration(
          color: isLightMode ? Colors.white : boarderColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: boarderColor, width: 1.5)
      ),
      child: ClipOval(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: EdgeInsets.all(2.0 * s),
            child: image,
          ),
        ),
      ),
    );
  }
}