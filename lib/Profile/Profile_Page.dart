import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Profile/Profile_Edit_Page.dart';
import 'package:untitled1/Profile/Settings_Page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 30, top: 20),
          child: Text(
            "Προφίλ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileEditPage()));
            },
            child: Text("Επεξεργασία Προφίλ")),
        TextButton.icon(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsPage()));
          },
          icon: Icon(Icons.settings),
          label: Text("Ρυθμίσεις"),
        ),
      ],
    );
  }
}
