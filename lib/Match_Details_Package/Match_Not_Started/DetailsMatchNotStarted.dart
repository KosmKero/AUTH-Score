import 'package:flutter/material.dart';
import '../../Data_Classes/Match.dart';
import '../../Data_Classes/Team.dart';
import '../../Team_Display_Page_Package/TeamDisplayPage.dart';
import '../../globals.dart';


//ΤΟ ΚΟΜΜΑΤΙ ΑΥΤΟ ΑΦΟΡΑ ΟΛΟ ΤΟ ΥΠΟΛΟΙΠΟ ΜΕΡΟΣ ΤΗΣ ΣΕΛΙΔΑΣ
class DetailsMatchNotStarted extends StatelessWidget {
  const DetailsMatchNotStarted({super.key, required this.match});
  final Match match;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 70,),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child:Text(
                greek?'Ποιός Θα κερδίσει?🏆':"Who will win?🏆",
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.italic
                ),
              ),
            ),
            SizedBox(height: 8),
            BettingChooser(), //TO KOYMΠΙ ΜΕ ΤΙΣ 3 ΕΠΙΛΟΓΕΣ (1Χ2)
            SizedBox(
              height: 70,
            ),
            Text(
              greek?'Αποτελέσματα τελευταίων 5 αγωνιστικών:':"Result of the last 5 games:",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Padding( //ΑΦΟΡΑ ΤΗΝ ΑΠΟΣΤΑΣΗ ΑΠΟ ΤΑ ΚΥΚΛΑΚΙΑ ΜΕ ΤΟ ΟΝΟΜΑ
              padding: const EdgeInsets.symmetric(horizontal:10.0),
              child: Column(
                children: [ //ΔΗΜΙΟΥΡΓΕΙ ΤΙΣ ΟΜΑΔΕΣ
                  TeamFormWidget(team: match.homeTeam, results: match.homeTeam.last5Results),
                  SizedBox(height: 5),
                  TeamFormWidget(team: match.awayTeam, results: match.awayTeam.last5Results),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ));
  }
}

class BettingChooser extends StatefulWidget {
  const BettingChooser({super.key});

  @override
  State<BettingChooser> createState() => _BettingChooserState();
}

//ΥΛΟΠΟΙΕ ΤΟ ΚΟΥΜΠΙ ΜΕ ΤΙΣ 3 ΕΠΟΙΛΟΓΕΣ
class _BettingChooserState extends State<BettingChooser> {
  String _selected = '';
  int count1 = 0;
  int countX = 0;
  int count2 = 0;
  bool hasChosen = false;

  void _updateCount(String value) {
    if(hasChosen)return;
    setState(() {
      hasChosen =true;
      _selected  = value;
      if(_selected=='1') count1++;
      if(_selected=='X') countX++;
      if(_selected=='2') count2++;
    });
  }

  double getTotalCount() => (count1 + countX + count2).toDouble();

  String getPercentage(String value){
    if (getTotalCount() == 0) return "0";
    if (value=='X') return ((countX / getTotalCount()) * 100).toStringAsFixed(1)+"%";
    if (value=='1') return ((count1 / getTotalCount()) * 100).toStringAsFixed(1)+"%";
    if (value=='2') return ((count2 / getTotalCount()) * 100).toStringAsFixed(1)+"%";
    return "0";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: Column(
      children: [
        SizedBox(
          width: 320,
        child: SegmentedButton<String>(
          segments: [
            ButtonSegment(value: '1', label: Text(hasChosen ? getPercentage("1") : "1",
              style:  TextStyle(fontSize: 15,),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              ),
            ),

            ButtonSegment(value: 'X', label: Text(hasChosen ? getPercentage("X") :'X',style: TextStyle(fontSize: 15),)),

            ButtonSegment(value: '2', label: Text(hasChosen ? getPercentage("2") :'2',style: TextStyle(fontSize: 15,))),
          ],
          style: ButtonStyle(
              fixedSize: WidgetStateProperty.all(Size(540, 50)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(9),side: BorderSide(color: Colors.black,width: 1.5))),
              backgroundColor: WidgetStateProperty.all(Color.fromARGB(255, 243, 246, 255)),
          ),
          showSelectedIcon: true,
          selected: _selected != null ? {_selected!} : {},
          onSelectionChanged: hasChosen
              ? null
              : (newSelection) {
            _updateCount(newSelection.first);
          },
        ),
        ),
        SizedBox(height: 10),
       ],
      )
    );
  }
}


//ΑΦΟΡΑ ΤΗΝ ΚΑΤΑΣΚΕΥΗ ΤΩΝ ΟΝΟΜΑΤΩΝ ΤΩΝ ΟΜΑΔΩΝ ΣΤΟ ΚΑΤΩ ΜΕΡΟΣ
class TeamFormWidget extends StatelessWidget {
  final Team team;
  final List<String> results; // "W" for Win, "D" for Draw, "L" for Loss

  const TeamFormWidget({super.key, required this.team, required this.results});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 1,top: 10),
      child: Row(
        children: [
          // Team Name (Left)
          SizedBox(
            width: 155, // Ensures team names align
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamDisplayPage(team)),
                );
              },
              child: Text(
                team.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(width: 30), // Space between name and results

          // Result Circles (Right, aligned)
          Row(
            children: results
                .map((result) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _buildResultIcon(result),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIcon(String result) {
    IconData icon;
    Color color;

    switch (result) {
      case "W":
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case "D":
        icon = Icons.remove_circle;
        color = Colors.grey;
        break;
      case "L":
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 30);
  }
}

