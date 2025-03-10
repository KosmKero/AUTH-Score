import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/Match_Details_Package/Match_Not_Started/Match_Not_Started_Details_Page.dart';
import 'package:untitled1/Match_Details_Package/Match_Started_Details_Page.dart';
import '../Data_Classes/Match.dart';

class matchDetailsPage extends StatelessWidget {
  final Match match;
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
    final match = Provider.of<Match>(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(50, 5, 150, 200),),
      body: matchProgress(match),


    );
  }

  Widget matchProgress(Match match){
    if (!match.hasMatchStarted) {
      return MatchNotStartedDetails(match: match,);
    }
    else {
      return matchStartedPage(match: match,);
    }
  }
}
