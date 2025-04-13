import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import '../main.dart';


final TextEditingController _textController1 = TextEditingController();
final TextEditingController _textController2 = TextEditingController();
final TextEditingController _textController3 = TextEditingController();

bool isSure=false;

class ChangePassword extends StatefulWidget
{
  final AppUser user;
  const ChangePassword({super.key, required this.user});

  @override
  State<ChangePassword> createState() => _ChangePassword();
}


class _ChangePassword extends State<ChangePassword>
{
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
        appBar: CreateAppBar(),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  children: [
                    CreateBody(user: widget.user),
                  ]
              )
          ),
        )
    );
  }
}



class CreateAppBar extends StatelessWidget implements PreferredSizeWidget
{
  const CreateAppBar({super.key});

  @override
  Widget build(BuildContext context)
  {
    return AppBar(
        backgroundColor: Color.fromARGB(255,5,0,170),
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back arrow color here
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 0,top: 10),
          child: Text(
              greek?"Αλλαγή κωδικού πρόσβασης":"Change password",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Trajan Pro',
                  fontStyle: FontStyle.italic
              )
          ),
        )
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);

}

class CreateBody extends StatefulWidget
{
  final AppUser user;

  const CreateBody({super.key, required this.user});

  @override
  State<CreateBody> createState() => _CreateBody();
}

class _CreateBody extends State<CreateBody>
{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(right: greek?225:250,top: 20),
            child: Text(
                greek?"Όνομα χρήστη":"Username",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                )
            )
        ),

        Padding(
          padding: EdgeInsets.only(top: 15),
          child:TextField(
            controller: _textController1,
            decoration: InputDecoration(
              // prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 4),
              ),
              hintText: 'Πληκτρολόγησε το όνομα χρήστη σου...',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 20,),

        Padding(
            padding: EdgeInsets.only(right: greek?200:220,top: 20),
            child: Text(
                greek?"Παλιός κωδικός":"Old password",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                )
            )
        ),

        Padding(
          padding: EdgeInsets.only(top: 15),
          child:TextField(
            controller: _textController2,
            decoration: InputDecoration(
              // prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 4),
              ),
              hintText: 'Πληκτρολόγησε τον κωδικό σου...',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
        SizedBox(height: 20,),

        Padding(
            padding: EdgeInsets.only(right: greek?170:210,top: 20),
            child: Text(
                greek?"Καινούριος κωδικός":"New password",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                )
            )
        ),

        Padding(
          padding: EdgeInsets.only(top: 15),
          child:TextField(
            controller: _textController3,
            decoration: InputDecoration(
              // prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.black87, width: 4),
              ),
              hintText: 'Πληκτρολόγησε τον καινούριο κωδικό...',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),

        SizedBox(height: 80,),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Note: You must remember your new password to connect to your account!!",
            style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w700
            ),
          ),
        ),

        CreateConfirmButton(user: widget.user)
      ],
    );
  }
}



class CreateConfirmButton extends StatelessWidget {
  final AppUser user;

  const CreateConfirmButton({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: CreateConfrimButton(),
    );
  }
}


class CreateConfrimButton extends StatelessWidget
{
  const CreateConfrimButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: ElevatedButton(
        onPressed: () {
          updatePassword(context, _textController1.text,_textController2.text,_textController3.text);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          // Button background color
          foregroundColor: Colors.white,
          // Text color
          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
          // Button padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 5, // Shadow effect
        ),
        child: Text(
          greek?"Επιβεβαίωση":"Confirm",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Future<void> updatePassword(BuildContext context, String username, String oldPassword,String newPassword) async {
  try {
    // Find the user document
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('Username', isEqualTo: username)
        .limit(1)
        .get();


    if (querySnapshot.docs.isNotEmpty)
    {

      DocumentReference userDocRef = querySnapshot.docs.first.reference;
      DocumentSnapshot userSnapshot = await userDocRef.get();

      if (userSnapshot.get("Password").toString() != oldPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar( //ΕΜΦΑΝΙΖΩ ΜΗΝΥΜΑ ΛΑΘΟΥΣ ΑΝ ΕΧΕΙ ΚΑΠΟΙΟ ΠΕΔΙΟ ΚΕΝΟ
            content: Text('The password does not match the username!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
      else {
        bool userConfirmed = await _showMyDialog(context);

        if (userConfirmed) {
          // Get the user document reference
          DocumentReference userDocRef = querySnapshot.docs.first.reference;

          // Update the username in Firestore
          await userDocRef.update({'Password': newPassword});

          AppUser user = AppUser(
              username,
              globalUser.university,
              [],
              [],
              "user"
          );

          // Update the globalUser variable
          globalUser = user;

          _textController1.clear();
          _textController2.clear();
          _textController3.clear();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        }
      }
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar( //ΕΜΦΑΝΙΖΩ ΜΗΝΥΜΑ ΛΑΘΟΥΣ ΑΝ ΕΧΕΙ ΚΑΠΟΙΟ ΠΕΔΙΟ ΚΕΝΟ
          content: Text('This username was not found!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    // ...error handling
  }
}


Future<bool> _showMyDialog(BuildContext context) async {
  bool result = false;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmation'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to change your password?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Decline'),
            onPressed: () {
              result = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              result = true;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  return result;
}