import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/API/Match_Handle.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/MatchDetails.dart';
import '../Match_Details_Package/Match_Details_Page.dart';

class KnockOutsPage extends StatelessWidget {
  const KnockOutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(

        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          //scrollDirection: Axis.vertical,
          child: Container(
            color: darkModeNotifier.value?darkModeBackGround: lightModeBackGround,
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
                      child: knockOutMatchUp(match: playOffMatches[index]), // Παράδειγμα δεδομένων
                    ),
                  ),
                ),
                // Στήλη με τις γραμμές
                Column(
                  mainAxisAlignment: MainAxisAlignment
                      .start, // Στοιχίστε τα στοιχεία στην αρχή
                  children: [
                    SizedBox(height: 45), Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 86), Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 86), Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 86), Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 86), Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 86), Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 86), Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 86), Container(width: 20, height: 2, color: Colors.black),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 45,
                    ),
                    Container(width: 2, height: 90, color: Colors.black),
                    SizedBox(height: 86),
                    Container(width: 2, height: 90, color: Colors.black),
                    SizedBox(height: 86),
                    Container(width: 2, height: 90, color: Colors.black),
                    SizedBox(height: 86),
                    Container(width: 2, height: 90, color: Colors.black),
                    //SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 86,
                    ),
                    Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 176),
                    Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 176),
                    Container(width: 20, height: 2, color: Colors.black),
                    SizedBox(height: 176),
                    Container(width: 20, height: 2, color: Colors.black),
                    //SizedBox(height: 176),
                  ],
                ),
                Column(
                  children: List.generate(
                    4,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: knockOutMatchUp(match:
                      playOffMatches[index+8]), // Παράδειγμα δεδομένων
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 86,
                    ),
                    Container(width: 10, height: 2, color: Colors.black),
                    SizedBox(height: 176),
                    Container(width: 10, height: 2, color: Colors.black),
                    SizedBox(height: 176),
                    Container(width: 10, height: 2, color: Colors.black),
                    SizedBox(height: 176),
                    Container(width: 10, height: 2, color: Colors.black),
                    //SizedBox(height: 176),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 86,
                    ),
                    Container(width: 2, height: 180, color: Colors.black),
                    SizedBox(height: 176),
                    Container(width: 2, height: 180, color: Colors.black),
                    //SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176,
                    ),
                    Container(width: 30, height: 2, color: Colors.black),
                    SizedBox(height: 264 + 89),
                    Container(width: 30, height: 2, color: Colors.black),
                    //SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: List.generate(
                    2,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 138),
                      child: knockOutMatchUp(match:
                      playOffMatches[index+12]), // Παράδειγμα δεδομένων
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176,
                    ),
                    Container(width: 10, height: 2, color: Colors.black),
                    SizedBox(height: 264 + 89),
                    Container(width: 10, height: 2, color: Colors.black),
                    // SizedBox(height: 86),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176,
                    ),
                    Container(width: 2, height: 357, color: Colors.black),
                    //SizedBox(height: 264 + 89),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 176 + 356 / 2,
                    ),
                    Container(width: 45, height: 2, color: Colors.black),
                    SizedBox(height: 264 + 89),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 317,
                    ),
                    knockOutMatchUp(match: playOffMatches[14])
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
                  builder: (context) => matchDetailsPage(match!)));
        }
      },
      child: Card(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                        height: 25 ,
                        width:  45 ,
                        child: (match!=null) ? match!.homeTeam.image : Image.asset('fotos/default_team_logo.png')),
                    Text((match!=null) ? match!.homeTeam.initials : "N/A", style: TextStyle(fontSize: 13 )),
                    //if (match.hasMatchStarted)
                    (match!=null && match!.hasMatchStarted)? Text(match!.scoreHome.toString(), style: TextStyle(fontSize:  17,color: (match!.hasMatchFinished)? Colors.black : Colors.red )) : SizedBox.shrink()
                  ],
                ),
                SizedBox(
                  width: 5,
                ),
                Column(children: [
                  SizedBox(
                      height: 25 ,
                      width:  45 ,
                      child: (match!=null) ? match!.awayTeam.image: Image.asset('fotos/default_team_logo.png')),
                  Text(
                    (match!=null) ? match!.awayTeam.initials : "N/A",
                    style: TextStyle(fontSize: 13 ),
                  ),
                  //if (match.hasMatchStarted) Text(match.scoreAway.toString())
                (match!=null && match!.hasMatchStarted)? Text(match!.scoreAway.toString(), style: TextStyle(fontSize:  17, color: (match!.hasMatchFinished)? Colors.black : Colors.red )) : SizedBox.shrink()
                ])
              ],
            ),
              (match==null) ? SizedBox(height:30,child: Center(child: Text("-"),)) : ( !match!.hasMatchStarted) ? SizedBox(height:27,child: Center(child: Text(match!.dateString))) : SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

