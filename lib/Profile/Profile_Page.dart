import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Firebase_Handle/user_handle_in_base.dart';
import 'package:untitled1/Profile/ChangePassword.dart';
import 'package:untitled1/Profile/ChangeUserName.dart';
import 'package:untitled1/Profile/admin_request_screen.dart';
import 'package:untitled1/Profile/requests_and_admins_package/requests_and_admins_page.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import 'LogInScreen.dart';

String selectedLanguage = greek?"Ελληνικά":"English";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final AppUser user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void pressed(){
    UserHandleBase().addControlledTeamToFirestore(["Ολυμπιακός"] );
  }


  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton( onPressed: () {
                   pressed();
                          }, child: Text("Kane me admin tou thryloy")),
                TextButton(onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>RequestApprovalScreen(),
                      )
                  );
                }, child: Text("see Requests")),
                TextButton(onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>AdminRequestScreen(),
                      )
                  );
                }, child: Text("req"))
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 5, top: 15, left: 5),
              child: Text(
                greek? "Επεξεργασία Προφίλ" : "Edit profile",
                style: TextStyle(
                    fontSize: greek? 21:23,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Trajan Pro',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // --- Εικόνα κάτω από το "Επεξεργασία Προφίλ" ---
            Padding(
              padding: EdgeInsets.only(top: 30,left: 130),// Κεντράρει την εικόνα
              child: Image.asset(
                "fotos/user.jpg",
                // Σιγουρέψου ότι είναι στη σωστή διαδρομή!
                width: 100,
                height: 100,
              ),
            ),

            SizedBox(height: 20), // Διάστημα μεταξύ εικόνας και κουμπιών

            if (isLoggedIn)
              Padding(
                padding: EdgeInsets.only(bottom: 1, top: 5, right: greek?170:220),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeUserName(user: widget.user),
                      )
                    );
                  },
                  child: Text(
                    greek?"Αλλαγή ονόματος χρήστη": "Change username",
                    style: TextStyle(fontSize: greek?16:18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (isLoggedIn)
              Padding(
                padding: EdgeInsets.only(bottom: 25, top: 1, right: greek?170: 220),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePassword(user: widget.user),
                        )
                    );
                  },
                  child: Text(
                    greek?"Αλλαγή κωδικού σύνδεσης":"Change password",
                    style: TextStyle(fontSize:greek?16:18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            LogInButton(user: widget.user, onLoginStateChanged: () {
              setState(() {}); // Refresh ProfilePage
            }),

            SizedBox(height: 20),

            Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                        greek?"Επιλογή Γλώσσας":"Choose Language",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                    ),
                ),
                SizedBox(width: 10),

                Padding(
                    padding: EdgeInsets.only(left: 30),
                    child:
                    DropdownButton<String>(
                      value: greek?"Ελληνικά":"English", // Αποθηκευμένη επιλογή
                      onChanged: (String? newValue)
                      {
                        selectedLanguage = newValue!;
                        setState(()
                        {
                          if(selectedLanguage == "English")
                            greek=false;
                          else
                            greek=true;

                          if(isLoggedIn)
                            updateUserChar(globalUser.username,"Language");
                        }
                        );
                      },
                    items:
                        [
                          DropdownMenuItem<String>(
                            value: "Ελληνικά",
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Text("Ελληνικά"),
                              ],
                            ),
                          ),
                          DropdownMenuItem<String>(
                            value: "English",
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Text("English"),
                              ],
                            ),
                          ),
                        ]
                    ),
                ),
              ]
            ),

            SizedBox(height: 30,),


            Padding(
              padding: EdgeInsets.only(left: 5, bottom: 30),
              child: Row(
                children: [
                  Text(
                    greek?"Σκοτεινή λειτουργία":"Dark mode",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  OvalToggleButton(),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              height: 2,
              color: Colors.black87,
            ),
            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  Text(
                    greek?"Επικοινωνία για προβλήματα":"Communication for problems",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Text("Email: adamo@csd.auth.gr"),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.only(right: 45),
                    child: Text("Email: kosma pes email"),
                  ),
                  SizedBox(height: 30,)
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}



// LOGIN BUTTON THAT TRIGGERS PAGE REFRESH
class LogInButton extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLoginStateChanged; // Callback to refresh the page

  const LogInButton({super.key, required this.user, required this.onLoginStateChanged});

  @override
  State<LogInButton> createState() => _LogInButtonState();
}

class _LogInButtonState extends State<LogInButton> {
  @override
  Widget build(BuildContext context) {

    return Column(
        children:[
          Padding(
            padding: EdgeInsets.only(bottom: widget.user.isLoggedIn ? 70 : 70),
            child:
            TextButton(
              onPressed: () {
                setState(() {
                  if(!isLoggedIn) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LogInScreen(user: widget.user)));
                  }
                  else{
                    isLoggedIn=false;
                    globalUser=AppUser(" "," ",[ ], []);
                  }
                  //widget.user.changeLogIn(); // Toggle login state
                });
                widget.onLoginStateChanged(); // Notify ProfilePage to refresh
              },
              child: Text(
                isLoggedIn ? greek?"Αποσύνδεση":"Disconnect" : greek?"Σύνδεση/Δημιουργία Λογαριασμού":"Login/Create an account",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                  color: isLoggedIn ? Colors.red : Colors.blue,
                ),
              ),
            ),
          ),
        ]
    );
  }
}

//ΔΗΔΗΜΙΟΥΡΓΕΙ ΤΟ ΚΥΚΛΙΚΟ ΚΟΥΜΠΙ!!
class OvalToggleButton extends StatefulWidget {
  @override
  _OvalToggleButtonState createState() => _OvalToggleButtonState();
}


class _OvalToggleButtonState extends State<OvalToggleButton> {
  bool isToggled = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isToggled = !isToggled;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          color: isToggled ? Colors.black87 : Color.fromARGB(255, 192, 192, 192),
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 300),
          alignment: isToggled ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color : !isToggled ? Color.fromARGB(255, 192, 192, 192) : Colors.black87,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isToggled ? Icons.dark_mode : Icons.light_mode,
                size: 20,
                color: !isToggled? Color.fromARGB(255, 255, 255, 0) : Colors.white
              ),
            ),
          ),
        ),
      ),
    );
  }
}
