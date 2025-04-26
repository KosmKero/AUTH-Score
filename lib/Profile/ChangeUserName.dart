import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import '../Firebase_Handle/user_handle_in_base.dart';
import '../main.dart';


final TextEditingController _textController1 = TextEditingController();
final TextEditingController newUsernameText = TextEditingController();
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10,top: 50),
          child: Text(
            greek ? "Τωρινό όνομα χρήστη:" : "Current Username",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

// Εμφάνιση του τωρινού ονόματος χρήστη με πιο όμορφο σχεδιασμό
        Padding(
          padding: EdgeInsets.only(left:20,top: 15),
          child: Card(
            elevation: 4,  // Προσθήκη σκιάς για να ξεχωρίζει το κουτί
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),  // Γωνίες με στρογγυλεμένες ακμές
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                globalUser.username,  // Προβολή του τωρινού ονόματος χρήστη
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,  // Ελαφρώς έντονη γραφή για καλύτερη αναγνωσιμότητα
                  color: Colors.blueAccent,  // Χρώμα για να ξεχωρίζει
                ),
              ),
            ),
          ),
        ),


        Padding(
            padding: EdgeInsets.only(left: 10,top: 40),
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
            controller: newUsernameText,
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

        SizedBox(height: 40,),

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
        SizedBox(height: 90,),
        Center(child: CreateConfirmButton(user: widget.user))
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
    return ElevatedButton(
        onPressed: () {
          updateUsername(context, newUsernameText.text);
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
    );
  }
}


Future<void> updateUsername(BuildContext context, String newUsername) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greek ? 'Πρέπει να συνδεθείς για να αλλάξεις username!' : 'Please log in to change username.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (newUsername == globalUser.username) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greek
              ? 'Χρησιμοποιείς ήδη αυτό το όνομα χρήστη!'
              : 'You are already using this username!',),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }


    bool isAvailable = await UserHandleBase().isUsernameAvailable(newUsername);

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greek ? 'Το username υπάρχει ήδη. Παρακαλώ επίλεξε κάποιο άλλο!' : 'This username is already used!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    bool userConfirmed = await _showMyDialog(context);

    if (userConfirmed) {



      await FirebaseFirestore.instance
          .collection('users')  // Το όνομα της συλλογής
          .doc(user.uid)             // Το document με το UID ως κλειδί
          .update({
        'username': newUsername, // Το πεδίο που θέλεις να αλλάξεις
      });

      globalUser.changeUsername(newUsername);

      _textController1.clear();
      newUsernameText.clear();

      navigatorKey.currentState?.pushReplacementNamed('/home');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(greek ? 'Κάτι πήγε στραβά!' : 'Something went wrong!'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}



Future<bool> _showMyDialog(BuildContext context) async {
  bool result = false;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(greek ? 'Επιβεβαίωση' : 'Confirmation'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(greek ? 'Είσαι σίγουρος ότι θες να αλλάξεις username;' : 'Are you sure you want to change your username?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(greek ? 'Ακύρωση' : 'Decline'),
            onPressed: () {
              result = false;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(greek ? 'Επιβεβαίωση' : 'Approve'),
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