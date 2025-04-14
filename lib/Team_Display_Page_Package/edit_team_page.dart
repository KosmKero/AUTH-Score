import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';

import '../Data_Classes/Team.dart';

class TeamEditPage extends StatefulWidget {
  TeamEditPage(this.team);
  Team team;
  @override
  _TeamEditPageState createState() => _TeamEditPageState();
}

class _TeamEditPageState extends State<TeamEditPage> {
  final _formKey = GlobalKey<FormState>();

  String coach = '';
  String foundingYear = '';
  List<Map<String, String>> titles = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController titleYearController = TextEditingController();

  void addTitle() {
    if (titleController.text.isNotEmpty && titleYearController.text.isNotEmpty) {
      setState(() {
        titles.add({
          'title': titleController.text,
          'year': titleYearController.text,
        });
        titleController.clear();
        titleYearController.clear();
      });
    }
  }

  void removeTitle(int index) {
    setState(() {
      titles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Επεξεργασία Ομάδας')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Έτος Ίδρυσης: ${widget.team.foundationYear}'),
                keyboardType: TextInputType.number,
                onChanged: (val) => foundingYear = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Προπονητής: ${widget.team.coach}'),
                onChanged: (val) => coach = val,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (globalUser.controlTheseTeams(widget.team.name, null) && coach.isNotEmpty && foundingYear.isNotEmpty) {
                    await FirebaseFirestore.instance.collection('teams').doc(widget.team.name).set({
                      "Foundation Year": int.parse(foundingYear) ,
                      "Coach": coach,
                    }, SetOptions(merge: true));

                    widget.team.setCoachName(coach);
                    widget.team.setFoundationYear(int.parse(foundingYear));

                    Navigator.pop(context);
                  }
                },
                child: Text('Αποθήκευση'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
