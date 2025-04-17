import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import '../Data_Classes/MatchDetails.dart';
import '../globals.dart';

class matchDetailsPage extends StatelessWidget {
  final MatchDetails match;
  const matchDetailsPage(this.match, {Key? key,}): super(key: key);


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: match,
      child: _matchDetailsPageView(),
    );
  }
}

class _matchDetailsPageView extends StatelessWidget {
  const _matchDetailsPageView();

  //const MatchDetailsPage({super.key,required this.match});
  //final Match match;
  
  @override
  Widget build(BuildContext context) {
    final match = Provider.of<MatchDetails>(context);
    return Scaffold(

      appBar: AppBar(
        backgroundColor:darkModeNotifier.value?Colors.grey[900]: Color.fromARGB(50, 5, 150, 200),
        iconTheme: IconThemeData(color: darkModeNotifier.value?Colors.white:Colors.black),
      ),
      body: matchProgress(match),


    );
  }

  Widget matchProgress(MatchDetails match){
    if (!match.hasMatchStarted) {
      return MatchNotStartedDetails(match: match,);
    }
    else {
      return matchStartedPage(match: match,);
    }
  }
}
