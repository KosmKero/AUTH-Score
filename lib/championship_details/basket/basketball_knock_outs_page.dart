import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/basketMatches/basket_match_details.dart';
// TODO: Βάλε τα σωστά imports του Μπάσκετ σου
import '../../Data_Classes/basketball/basketMatch.dart';
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../../Match_Details_Package/Match_Details_Page.dart'; // Αν έχεις ξεχωριστό για μπάσκετ, άλλαξέ το
import '../../globals.dart';

class BasketballKnockOutsPage extends StatefulWidget {
  const BasketballKnockOutsPage({super.key, required this.playOffMatches});

  final Map<int, BasketMatch> playOffMatches;

  @override
  State<BasketballKnockOutsPage> createState() => _BasketballKnockOutsPageState();
}

class _BasketballKnockOutsPageState extends State<BasketballKnockOutsPage> {
  @override
  void initState() {
    logScreenViewSta(screenName: 'Basketball Knock Outs', screenClass: 'Basketball Knock Outs');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Container(
            color: darkModeNotifier.value ? const Color(0xFF121212) : lightModeBackGround,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 5),
                // --- ΟΙ ΓΡΑΜΜΕΣ ΚΑΙ Η ΔΟΜΗ ΕΙΝΑΙ ΑΚΡΙΒΩΣ ΙΔΙΑ ΜΕ ΤΟ ΠΟΔΟΣΦΑΙΡΟ ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    8,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: KnockOutMatchUpBasket(match: widget.playOffMatches[index]),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 45),   Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 45),
                    Container(width: 2, height: 94.3, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), const SizedBox(height: 90.4),
                    Container(width: 2, height: 94.3, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), const SizedBox(height: 90.4),
                    Container(width: 2, height: 94.3, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]), const SizedBox(height: 90.4),
                    Container(width: 2, height: 94.3, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 89),
                    Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), const SizedBox(height: 183),
                    Container(width: 20, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]), const SizedBox(height: 183),
                    Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), const SizedBox(height: 183),
                    Container(width: 20, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                  ],
                ),
                Column(
                  children: List.generate(
                    4,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: KnockOutMatchUpBasket(match: widget.playOffMatches[index+8]),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 89),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), const SizedBox(height: 183),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), const SizedBox(height: 183),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), const SizedBox(height: 183),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 89),
                    Container(width: 2, height: 187, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]), const SizedBox(height: 183),
                    Container(width: 2, height: 187, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 176),
                    Container(width: 30, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]), const SizedBox(height: 275 + 89),
                    Container(width: 30, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                  ],
                ),
                Column(
                  children: List.generate(
                    2,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 138),
                      child: KnockOutMatchUpBasket(match: widget.playOffMatches[index+12]),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 176),
                    Container(width: 10, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    const SizedBox(height: 264 + 89),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 176),
                    Container(width: 2, height: 357, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 176 + 356 / 2),
                    Container(width: 45, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                    const SizedBox(height: 264 + 89),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 313),
                    KnockOutMatchUpBasket(match: widget.playOffMatches[14])
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KnockOutMatchUpBasket extends StatelessWidget {
  final BasketMatch? match;

  const KnockOutMatchUpBasket({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    if (match == null) {
      return const knockOutMatchUpBasketView();
    }
    return ChangeNotifierProvider<BasketMatch>.value(
      value: match!,
      child: const knockOutMatchUpBasketView(),
    );
  }
}

class knockOutMatchUpBasketView extends StatefulWidget {
  const knockOutMatchUpBasketView({super.key});

  @override
  State<knockOutMatchUpBasketView> createState() => _KnockOutMatchUpBasketState();
}

class _KnockOutMatchUpBasketState extends State<knockOutMatchUpBasketView> {
  @override
  Widget build(BuildContext context) {
    final match = Provider.of<BasketMatch?>(context);
    return GestureDetector(
      onTap: () {
        if (match != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => basketMatchDetailsPage(match)));
        }
      },
      child: Card(
        color: darkModeNotifier.value ? Colors.grey[800] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            height: 25,
                            width: 45,
                            child: (match != null) ? match.homeTeam.image : Image.asset('fotos/default_team_logo.png')),
                        Text(
                          (match != null) ? match.homeTeam.initials : "N/A",
                          style: TextStyle(fontSize: 13, color: darkModeNotifier.value ? Colors.white : Colors.black),
                        ),
                        if (match != null && match.hasMatchStarted)
                          Text(
                            (match.homeScore).toString(),
                            style: TextStyle(
                              fontSize: 17,
                              color: (match.hasMatchFinished) ? (darkModeNotifier.value ? Colors.white : Colors.black) : Colors.red,
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0, right: 3.0, top: (match == null || !(match.hasMatchStarted)) ? 23.5 : 0),
                      child: Center(
                        child: Text("vs", style: TextStyle(fontSize: 14, color: darkModeNotifier.value ? Colors.white70 : Colors.black54)),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                            height: 25,
                            width: 45,
                            child: (match != null) ? match.awayTeam.image : Image.asset('fotos/default_team_logo.png')),
                        Text(
                          (match != null) ? match.awayTeam.initials : "N/A",
                          style: TextStyle(fontSize: 13, color: darkModeNotifier.value ? Colors.white : Colors.black),
                        ),
                        if (match != null && match.hasMatchStarted)
                          Text(
                            (match.awayScore).toString(),
                            style: TextStyle(
                              fontSize: 17,
                              color: (match.hasMatchFinished) ? (darkModeNotifier.value ? Colors.white : Colors.black) : Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              (match == null)
                  ? const SizedBox(height: 27, child: Center(child: Text("-")))
                  : (!match.hasMatchStarted)
                  ? SizedBox(height: 27, child: Center(child: Text(match.dateString, style: TextStyle(color: darkModeNotifier.value ? Colors.white : Colors.black))))
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}