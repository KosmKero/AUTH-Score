import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import '../Firebase_Handle/user_handle_in_base.dart';
import '../main.dart';


final TextEditingController _textController1 = TextEditingController();
final TextEditingController _textController2 = TextEditingController();
bool isSure=false;

class ChangeUserName extends StatefulWidget
{
  final AppUser user;
  const ChangeUserName({super.key, required this.user});

  @override
  State<ChangeUserName> createState() => _ChangeUserName();
}


class _ChangeUserName extends State<ChangeUserName>
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
        padding: EdgeInsets.only(left: 10,top: 10),
        child: Text(
          "Αλλαγή username",
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
          padding: EdgeInsets.only(right: greek?150:180,top: 60),
          child: Text(
            greek?"Τωρινό όνομα χρήστη":"Current Username",
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
              hintText: 'Enter your username...',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),

        Padding(
            padding: EdgeInsets.only(right: greek?120:200,top: 60),
            child: Text(
                greek?"Καινούριο όνομα χρήστη":"New Username",
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
              hintText: 'Enter your new username...',
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
            "Note: You must remember your new username to connect to your account!!",
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


class CreateConfrimButton extends StatelessWidget {
  const CreateConfrimButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: ElevatedButton(
        onPressed: () {
          updateUsername(context, _textController1.text,_textController2.text);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,

          padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
          side: BorderSide(color: Colors.blue, width: 1),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 6, // Shadow effect
        ),
        child: Text(
          greek?"Επιβεβαίωση":"Confirm",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Trajan Pro',
          ),
        ),
      ),
    );
  }
}


Future<void> updateUsername(BuildContext context, String oldUsername, String newUsername) async {
  try {
    // Find the user document
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: oldUsername)
        .get();

    if (querySnapshot.docs.isNotEmpty)
    {
      bool userConfirmed = await _showMyDialog(context);
      bool isAvailable = await UserHandleBase().isUsernameAvailable(newUsername);

      if(isAvailable)
      {
        if (userConfirmed) {
          // Get the user document reference
          DocumentReference userDocRef = querySnapshot.docs.first.reference;

          // Update the username in Firestore
          await userDocRef.update({'username': newUsername});
          await userDocRef.update({"email": newUsername+"@myapp.com"});

          AppUser user = AppUser(
              newUsername,
              globalUser.university,
              [],
              []
          );

          // Update the globalUser variable
          globalUser = user;

          // Show success message
          /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Username updated successfully!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );*/
          _textController1.clear();
          _textController2.clear();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        }
      }
      else
        {
        SnackBar( //ΕΜΦΑΝΙΖΩ ΜΗΝΥΜΑ ΛΑΘΟΥΣ ΑΝ ΕΧΕΙ ΚΑΠΟΙΟ ΠΕΔΙΟ ΚΕΝΟ
            content: Text('This is already used!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),);
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
              Text('Are you sure you want to change your username?'),
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