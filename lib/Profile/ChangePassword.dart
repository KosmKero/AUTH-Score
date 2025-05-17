import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:untitled1/globals.dart';
import '../Data_Classes/AppUser.dart';
import '../ad_manager.dart';
import '../main.dart';


final TextEditingController _emailText = TextEditingController();
final TextEditingController _oldPasswordText = TextEditingController();
final TextEditingController _newPasswordText = TextEditingController();

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

  BannerAd? _bannerAd;

  bool _isBannerAdReady = false;

  void initState() {
    super.initState();
    _bannerAd = AdManager.createBannerAd(
      onStatusChanged: (status) {
        setState(() {
          _isBannerAdReady = status;
        });
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

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
        ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min, // Για να μην γεμίζει όλη την οθόνη
        children: [
          if (_isBannerAdReady && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
            padding: EdgeInsets.only(left: 10,top: 20),
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
            controller: _oldPasswordText,
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

        Padding(
            padding: EdgeInsets.only(left: 10,top: 30),
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
            controller: _newPasswordText,
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

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 50),
          child: Text(greek ? "Σημείωση: Πρέπει να θυμάσαι τον νέο σου κωδικό για να μπορέσεις να συνδεθείς στον λογαριασμό σου!" :
            "Note: You must remember your new password to connect to your account!!",
            style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w700
            ),
          ),
        ),

        Center(child: CreateConfirmButton(user: widget.user))
      ],
    );
  }
}


class CreateConfirmButton extends StatelessWidget
{
  const CreateConfirmButton({super.key, required this.user});
  final AppUser user;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50),
      child: ElevatedButton(
        onPressed: () {
          changePassword( _oldPasswordText.text,_newPasswordText.text,context);
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

Future<bool> changePassword(String oldPassword, String newPassword, BuildContext context) async {
  try {
    User user = FirebaseAuth.instance.currentUser!;

    // 1. Reauthenticate
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // 2. Change password
    await user.updatePassword(newPassword);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(greek ? 'Ο κωδικός άλλαξε με επιτυχία!' : 'Password changed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    navigatorKey.currentState?.pushReplacementNamed('/home');

    return true;
  } catch (e) {
    print("Error changing password: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(greek ? 'Αποτυχία αλλαγής κωδικού. Βεβαιώσου ότι έβαλες σωστό παλιό κωδικό.' : 'Failed to change password. Please ensure your old password is correct.'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
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