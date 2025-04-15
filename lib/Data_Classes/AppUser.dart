
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/globals.dart';

import 'MatchDetails.dart';
import 'Team.dart';

class AppUser
{
  String _username,_university;
  bool _isLoggedIn=false;
  late bool _isAdmin;

  List<String> favoriteList=[];
  List<String> _controlledTeams=[];

  AppUser(this._username,this._university,this.favoriteList,this._controlledTeams,String role){
    (role=="admin") ? (_isAdmin=true) : (_isAdmin=false);
  }

  String get username => _username;
  String get university => _university;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin=> _isAdmin;
  List<String> get controlledTeams=> _controlledTeams;


  void addFavoriteTeam(Team team){
    favoriteList.add(team.name);
  }
  void loggedIn(){
    _isLoggedIn=true;
  }


  void changeLogIn(){
    _isLoggedIn=!_isLoggedIn;
  }
  void userLoggedIn(){
    _isLoggedIn=true;
  }

  List<String> getFavoriteTeamList(){
    return favoriteList;
  }


  void addControlledTeam(Team team){
    _controlledTeams.add(team.name);
  }

  void addControlledTeams(List<String> teamsName){
    _controlledTeams.addAll(teamsName);
  }

  void makeAdmin(Team team){
    _isAdmin=true;
    addControlledTeam(team);
  }

  void makeUser(){
    _isAdmin=false;
  }


  bool controlTheseTeams(String team1,String? team2) {
    if (!_isAdmin) return false;
    for (String name in controlledTeams){
      if (name==team1 ){
        return true;
      }
      else if (team2!=null){
       if (team2==name){
         return true;
       }
      }

    }
    return false;
  }




  Future<void> updateUserStatsForMatch(MatchDetails match, String correctChoice) async {
    final matchKey = '${match.homeTeam.name}${match.awayTeam.name}${match.dateString}';
    final votesDoc = await FirebaseFirestore.instance.collection('votes').doc(matchKey).get();

    if (!votesDoc.exists || votesDoc.data()?['userVotes'] == null) {
      print("No votes found for this match.");
      return;
    }

    final Map<String, dynamic> userVotes = Map<String, dynamic>.from(votesDoc.data()!['userVotes']);

    for (final entry in userVotes.entries) {
      final String uid = entry.key;
      final String choice = entry.value;

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      int correct = 0;
      int total = 0;

      if (userDoc.exists && userDoc.data()?['predictions'] != null) {
        final predData = userDoc.data()!['predictions'];
        correct = predData['correctVotes'] ?? 0;
        total = predData['totalVotes'] ?? 0;
      }

      if (choice == correctChoice) {
        correct++;
      }
      total++;

      final accuracy = total > 0 ? (correct / total) * 100 : 0;

      await userDocRef.set({
        'predictions': {
          'correctVotes': correct,
          'totalVotes': total,
          'accuracy': accuracy,
        }
      }, SetOptions(merge: true));
    }

    print("Stats updated for all users who voted in $matchKey.");
  }




}