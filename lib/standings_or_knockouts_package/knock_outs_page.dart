import 'package:flutter/material.dart';
import 'package:untitled1/API/Match_Handle.dart';
import '../Data_Classes/Match.dart';

class KnockOutsPage extends StatelessWidget {
  const KnockOutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(

        color: Colors.grey[300],
         // Χρώμα φόντου
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Στοιχίστε στο αριστερό μέρος
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
                    child: knockOutMatchUp(MatchHandle().getAllMatches().first), // Παράδειγμα δεδομένων
                  ),
                ),
              ),
              // Στήλη με τις γραμμές
              Column(
                mainAxisAlignment: MainAxisAlignment.start, // Στοιχίστε τα στοιχεία στην αρχή
                children: [
                  SizedBox(height: 45),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 86),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 86),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 86),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 86),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 86),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 86),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 86),
                  Container(width: 20, height: 2, color: Colors.black),

                ],
              ),
              Column(
                children: [
                  SizedBox(height: 45,),
                  Container(width: 2, height: 90, color: Colors.black),SizedBox(height: 86),
                  Container(width: 2, height: 90, color: Colors.black),SizedBox(height: 86),
                  Container(width: 2, height: 90, color: Colors.black),SizedBox(height: 86),
                  Container(width: 2, height: 90, color: Colors.black),SizedBox(height: 86),

                ],
              ),
              Column(
                children: [
                  SizedBox(height: 86,),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 176),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 176),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 176),
                  Container(width: 20, height: 2, color: Colors.black),SizedBox(height: 176),
                ],
              ),
              Column(
                children: List.generate(
                  4,
                      (index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: knockOutMatchUp(MatchHandle().getAllMatches()[index]), // Παράδειγμα δεδομένων
                  ),
                ),
              ),
             Column(
               children: [
                 SizedBox(height: 86,),
                 Container(width: 10, height: 2, color: Colors.black),SizedBox(height: 176),
                 Container(width: 10, height: 2, color: Colors.black),SizedBox(height: 176),
                 Container(width: 10, height: 2, color: Colors.black),SizedBox(height: 176),
                 Container(width: 10, height: 2, color: Colors.black),SizedBox(height: 176),
               ],
             ),
              Column(
                children: [
                  SizedBox(height: 86,),
                  Container(width: 2, height: 180, color: Colors.black),SizedBox(height: 176),
                  Container(width: 2, height: 180, color: Colors.black),SizedBox(height: 86),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 176,),
                  Container(width: 30, height: 2, color: Colors.black),SizedBox(height: 264+89),
                  Container(width: 30, height: 2, color: Colors.black),SizedBox(height: 86),
                ],
              ),
              Column(
                children: List.generate(
                  2,
                      (index) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 138),
                    child: knockOutMatchUp(MatchHandle().getAllMatches()[index]), // Παράδειγμα δεδομένων
                  ),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 176,),
                  Container(width: 10, height: 2, color: Colors.black),SizedBox(height: 264+89),
                  Container(width: 10, height: 2, color: Colors.black),SizedBox(height: 86),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 176,),
                  Container(width: 2, height: 357, color: Colors.black),SizedBox(height: 264+89),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 176+356/2,),
                  Container(width: 45, height: 2, color: Colors.black),SizedBox(height: 264+89),
                ],
              ),
              Column(
                children: [
                  SizedBox(height: 317,),
                  knockOutMatchUp(MatchHandle().getAllMatches().first)
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget knockOutMatchUp(Match match) {
    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(height: 25,width: 25,child: Image.asset('fotos/teamlogo.png')),
              Text(match.homeInitials,style: TextStyle(fontSize: 15)),
              //if (match.hasMatchStarted)
              Text("1",style: TextStyle(fontSize: 17))
            ],
          ),
          SizedBox(width: 4,),
          Column(children: [
            SizedBox(height: 25,width: 25,child:Image.asset('fotos/csdfootball.png')),
            Text(match.awayInitials,style: TextStyle(fontSize: 15),),
            //if (match.hasMatchStarted) Text(match.scoreAway.toString())
            Text("1",style: TextStyle(fontSize: 17))


          ])
        ],
      ),
    );
  }

  Widget drawLines(){

    return Placeholder();
  }

}

class BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Σχεδίαση γραμμών μεταξύ θέσεων
    canvas.drawLine(Offset(50, 100), Offset(100, 150), paint);
    canvas.drawLine(Offset(50, 200), Offset(100, 150), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
