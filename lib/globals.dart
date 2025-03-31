library my_project.globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Data_Classes/AppUser.dart';


bool isLoggedIn=false;
String username = "";
AppUser globalUser= AppUser("","",[],[]);


bool greek = true;



void updateUserChar(String username,String key) async
{
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('Username', isEqualTo: username)
      .limit(1)
      .get();

  if(querySnapshot.docs.isNotEmpty)
    {
      DocumentReference userDocRef = querySnapshot.docs.first.reference;
      if(key=="Language") {
        await userDocRef.update({key:greek});
      }
    }

}


Future<bool> getValue(String username, String key) async
{
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('Username', isEqualTo: username)
      .limit(1)
      .get();

  if(querySnapshot.docs.isNotEmpty)
    {
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      return userDoc[key];
    }

  return true;
}