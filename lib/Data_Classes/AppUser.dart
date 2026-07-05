
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/change_notifier.dart';

import '../main.dart';
import 'MatchDetails.dart';
import 'Team.dart';

class AppUser
{
  String _username;
  final String _university,_email;
  bool _isLoggedIn=false;
  late  bool _isAdmin;
  final bool _isUpperAdmin;
  late final  bool _isSuperUser;

  final ValueNotifier<bool> _notifyAllMatches = ValueNotifier<bool>(false);

  List<String> favoriteList=[];
  List<String> _controlledTeams=[];
  List<String> _mainTeams = [];  //βασικοι αρχηγοι
  Map<String,bool>  _matchKeys={};
  AppUser(this._username,this._university,this.favoriteList,this._controlledTeams,this._mainTeams, String role,this._matchKeys,this._email, this._isUpperAdmin, this._isSuperUser,notifyAllMatches){
    (role=="admin") ? (_isAdmin=true) : (_isAdmin=false);

    _notifyAllMatches.value = notifyAllMatches;
  }

  String get username => _username;
  String get university => _university;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin=> _isAdmin;
  List<String> get controlledTeams=> _controlledTeams;
  Map<String,bool> get matchKeys=> _matchKeys;

  bool get isSuperUser => _isSuperUser;
  bool get isUpperAdmin => (_isUpperAdmin || _isSuperUser);

  ValueNotifier<bool> get notifyAllMatches => _notifyAllMatches;

  void setNotifyAllMatches(bool noti ){
    _notifyAllMatches.value=noti;
  }

  Future<void> addFavoriteTeam(Team team) async {
    favoriteList.add(team.name);

    for (MatchDetails match in upcomingMatches){
      if (match.homeTeam.name==team.name || match.awayTeam.name ==team.name ){
        match.enableNotify(true);

      }
    }
  }

  Future<void> removeFavoriteTeam(Team team) async {
    favoriteList.remove(team.name);

    for (MatchDetails match in upcomingMatches){
      if (match.homeTeam.name==team.name || match.awayTeam.name ==team.name ){
        match.enableNotify(false);

      }
    }
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

  bool isMainCaptainOf(String teamName) {
    if (_isSuperUser || _isUpperAdmin) return true; // SuperUser & Γραμματεία τα κάνουν όλα
    return _mainTeams.contains(teamName);
  }

  // Ελέγχει αν είναι απλός αρχηγός (μπορεί να βάλει σκορ, να δει το Roster κτλ)
  bool isCaptainOf(String teamName) {
    if (_isSuperUser || _isUpperAdmin) return true;
    return _controlledTeams.contains(teamName);
  }

  bool controlTheseTeamsFootball(String team1,String? team2) {
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

  void addMainTeam(String teamName) {
    if (!_mainTeams.contains(teamName)) {
      _mainTeams.add(teamName);
    }
    if (!_controlledTeams.contains(teamName)) {
      _controlledTeams.add(teamName); // Πρέπει να είναι και στα δύο!
    }
  }

  void changeUsername(String username){
    _username = username;
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