import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/API/Match_Handle.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../Match_Details_Package/Match_Details_Page.dart';
import '../globals.dart';

class KnockOutsPage extends StatefulWidget {
  KnockOutsPage({super.key, required this.playOffMatches} );
  Map<int, MatchDetails> playOffMatches;
  @override
  State<KnockOutsPage> createState() => _KnockOutsPageState();
}

class _KnockOutsPageState extends State<KnockOutsPage> {
  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Knock Outs Page',screenClass: 'Knock Outs Page');


    return Expanded(
      child: SingleChildScrollView(

        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          //scrollDirection: Axis.vertical,
          child: Container(
            color: darkModeNotifier.value?Color(0xFF121212): lightModeBackGround,
            // Χρώμα φόντου
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.start, // Στοιχίστε στο αριστερό μέρος
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 5),
                // Πρώτη στήλη με τους αγώνες
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    8,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: knockOutMatchUp(match: widget.playOffMatches[index]), // Παράδειγμα δεδομένων
                    ),
                  ),
                ),
                // Στήλη με τις γραμμές
                Column(
                  mainAxisAlignment: MainAxisAlignment
                      .start, // Στοιχίστε τα στοιχεία στην αρχή
                  children: [
                    SizedBox(height: 45),   Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 90.4), Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black: Colors.grey[400]),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 45,
                    ),
                    Container(width: 2, height: 94.3, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), SizedBox(height: 90.4),
                    Container(width: 2, height: 94.3, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), SizedBox(height: 90.4),
                    Container(width: 2, height: 94.3, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]), SizedBox(height: 90.4),
                    Container(width: 2, height: 94.3, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    //SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: 89),
                    Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), SizedBox(height: 183),
                    Container(width: 20, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]), SizedBox(height: 183),
                    Container(width: 20, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]), SizedBox(height: 183),
                    Container(width: 20, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    //SizedBox(height: 176),
                  ],
                ),
                Column(
                  children: List.generate(
                    4,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: knockOutMatchUp(match:
                      widget.playOffMatches[index+8]), // Παράδειγμα δεδομένων
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 89,
                    ),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),SizedBox(height: 183),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),SizedBox(height: 183),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),SizedBox(height: 183),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                    //SizedBox(height: 176),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 89,
                    ),
                    Container(width: 2, height: 187, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),SizedBox(height: 183),
                    Container(width: 2, height: 187, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    //SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176,
                    ),
                    Container(width: 30, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),SizedBox(height: 275 + 89),
                    Container(width: 30, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                    //SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: List.generate(
                    2,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 138),
                      child: knockOutMatchUp(match:
                      widget.playOffMatches[index+12]), // Παράδειγμα δεδομένων
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176,
                    ),
                    Container(width: 10, height: 2, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    SizedBox(height: 264 + 89),
                    Container(width: 10, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                    // SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176,
                    ),
                    Container(width: 2, height: 357, color:!darkModeNotifier.value?Colors.black: Colors.grey[400]),
                    //SizedBox(height: 264 + 89),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176 + 356 / 2,
                    ),
                    Container(width: 45, height: 2, color: !darkModeNotifier.value?Colors.black:Colors.grey[400]),
                    SizedBox(height: 264 + 89),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 313,
                    ),
                    knockOutMatchUp(match: widget.playOffMatches[14])
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

class knockOutMatchUp extends StatelessWidget {
  final MatchDetails? match;

  const knockOutMatchUp({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (match == null) {
      return const knockOutMatchUpView(); // χωρίς δεδομένα
    }

    return ChangeNotifierProvider<MatchDetails>.value(
      value: match!, // σίγουρα non-null εδώ
      child: const knockOutMatchUpView(),
    );
  }
}

class knockOutMatchUpView extends StatefulWidget {
  const knockOutMatchUpView({super.key});


  @override
  State<knockOutMatchUpView> createState() => _knockOutMatchUpState();
}

class _knockOutMatchUpState extends State<knockOutMatchUpView> {

  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchDetails?>(context);
    return GestureDetector(

      onTap: () {
        if (match!=null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => matchDetailsPage(match)));
        }
      },
      child: Card(
        
        color:darkModeNotifier.value?Colors.grey[800]:Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.stretch, // απαραίτητο!
                  children: [
                    Column(
                      children: [
                        SizedBox(
                            height: 25,
                            width: 45,
                            child: (match != null)
                                ? match.homeTeam.image
                                : Image.asset('fotos/default_team_logo.png')),
                        Text(
                          (match != null) ? match.homeTeam.initials : "N/A",
                          style: TextStyle(
                              fontSize: 13,
                              color: darkModeNotifier.value ? Colors.white : Colors.black),
                        ),
                        Row(
                          children: [
                            if (match != null && match.hasMatchStarted)
                              Text(
                                (match.homeScore).toString(),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: (match.hasMatchFinished)
                                      ? (darkModeNotifier.value ? Colors.white : Colors.black)
                                      : Colors.red,
                                ),
                              ),
                            if (match != null && match.isPenaltyTime)
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  ('(${match.penaltyScoreHome})').toString(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: (match.hasMatchEndedFinal)
                                        ? (darkModeNotifier.value ? Colors.white : Colors.black)
                                        : Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // η παύλα στο κέντρο:
                    Padding(
                      padding: EdgeInsets.only(left: 3.0,right: 3.0,top: (match == null || !(match.hasMatchStarted)) ? 23.5 : 0),
                      child: Center(
                        child: Text(
                          "vs",
                          style: TextStyle(
                            fontSize: 14,
                            color: darkModeNotifier.value ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                            height: 25,
                            width: 45,
                            child: (match != null)
                                ? match.awayTeam.image
                                : Image.asset('fotos/default_team_logo.png')),
                        Text(
                          (match != null) ? match.awayTeam.initials : "N/A",
                          style: TextStyle(
                            fontSize: 13,
                            color: darkModeNotifier.value ? Colors.white : Colors.black,
                          ),
                        ),

                          Row(
                            children: [
                              if (match != null && match.hasMatchStarted)
                              Text(
                                (match.awayScore).toString(),
                                style: TextStyle(
                                  fontSize: 17,
                                  color: (match.hasMatchFinished)
                                      ? (darkModeNotifier.value ? Colors.white : Colors.black)
                                      : Colors.red,
                                ),
                              ),
                              if (match != null && match.isPenaltyTime)
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    ('(${match.penaltyScoreAway})').toString(),
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: (match.hasMatchEndedFinal)
                                          ? (darkModeNotifier.value ? Colors.white : Colors.black)
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              (match==null) ? SizedBox(height:27,child: Center(child: Text("-"),)) : ( !match.hasMatchStarted) ? SizedBox(height:27,child: Center(child: Text(match.dateString,style:TextStyle( color: darkModeNotifier.value? Colors.white:Colors.black) ))) : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}

