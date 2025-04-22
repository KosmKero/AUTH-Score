import 'package:flutter/material.dart';
import 'package:untitled1/Profile/admin/see_feedback.dart';
import 'admins_handle.dart';
import 'request_approval_or_disapproval.dart';

class RequestApprovalScreen extends StatefulWidget {
  @override
  State<RequestApprovalScreen> createState() => _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends State<RequestApprovalScreen> {
  int selectedIndex=0;
  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request Handle')),
      body: Column(
        children: [
          _NavigationButtons(onSectionChange: _changeSection),
           selectedIndex==0 ? Expanded(child: RequestHandlePage()): selectedIndex==1 ? AdminListWidget() : Expanded(child: FeedbackViewPage())
        ],
      ),
    );
  }
}

//ΑΦΟΡΑ ΤΑ 2 ΚΟΥΜΠΙΑ!!
class _NavigationButtons extends StatefulWidget {
  final Function(int) onSectionChange;

  const _NavigationButtons({Key? key, required this.onSectionChange})
      : super(key: key);

  @override
  State<_NavigationButtons> createState() => _NavigationButtonsState();
}

class _NavigationButtonsState extends State<_NavigationButtons> {
  int selectedIndex = 0;

  void _onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onSectionChange(index); // Notify parent widget
  }

  //ΔΗΜΙΟΥΡΓΕΙ ΤΟΝ ΧΩΡΟ ΤΩΝ 3 ΚΟΥΜΠΙΩΝ
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      width: double.infinity,
      child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextButton("See Requests", 0),
            SizedBox(width: 10),
            _buildTextButton("See Admins", 1),
            SizedBox(width: 10,),
            _buildTextButton("See Feedback", 2),
          ],
        ),
    );
  }

  //ΔΗΜΙΟΥΡΓΕΙ ΤΑ 3 ΚΟΥΜΠΙΑ(ΛΕΠΤΟΜΕΡΕΙΕΣ ΑΓΩΝΕΣ ΚΑΙ ΠΑΙΧΤΕΣ)
  Widget _buildTextButton(String text, int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        _onButtonPressed(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 17,
              color: isSelected ? Colors.blue : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 3), // Απόσταση μεταξύ κειμένου και γραμμής
          if (isSelected)
            Container(
              width: 60, // Μήκος γραμμής
              height: 3, // Πάχος γραμμής
              color: Colors.blue, // Χρώμα γραμμής
            ),
        ],
      ),
    );
  }
}

