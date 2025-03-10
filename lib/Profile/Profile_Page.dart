import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Profile/Profile_Edit_Page.dart';
import 'package:untitled1/Profile/Settings_Page.dart';
import '../Data_Classes/User.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key,required this.user});
  final User user;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 30, top: 20),
            child: Text(
              "Ρυθμίσεις",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 5, top: 5, left: 5),
          child: Text("Επεξεργασία Προφίλ",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 1, top: 5, left: 20),
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Αλλαγή Username",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            )),
        Padding(
            padding: EdgeInsets.only(bottom: 25, top: 1, left: 20),
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Αλλαγή password",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            )),

        LogInButton(user: user)
        /* TextButton.icon(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SettingsPage()));
          },
          icon: Icon(
            Icons.settings,
          ),
          label: Text("Ρυθμίσεις",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
        ),
         */
      ],
    );
  }
}

class LogInButton extends StatefulWidget {


  const LogInButton({super.key,required this.user});
  final User user;

  @override
  State<LogInButton> createState() => _LogInButtonState();
}

class _LogInButtonState extends State<LogInButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 100, top: 1, left: 5),
        child: TextButton(
          onPressed: () {
            setState(() {
              widget.user.changeLogIn();
            });


          },
          child: !widget.user.isLoggedIn? Text(
            "Σύνδεση",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.blue),
          ): Text(
            "Αποσύνδεση",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.red),
          ),
        )
    );
  }
}

