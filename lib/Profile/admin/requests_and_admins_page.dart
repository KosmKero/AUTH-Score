import 'package:flutter/material.dart';
import 'package:untitled1/Profile/admin/pinWatch.dart';
import 'package:untitled1/Profile/admin/see_feedback.dart';
import 'package:untitled1/Profile/admin/user_statistics.dart';
import 'admins_handle.dart';
import 'request_approval_or_disapproval.dart';
import 'package:untitled1/globals.dart';

class RequestApprovalScreen extends StatefulWidget {
  @override
  State<RequestApprovalScreen> createState() => _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends State<RequestApprovalScreen> {
  late int selectedIndex;

  void _changeSection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    if (!globalUser.isSuperUser && globalUser.isUpperAdmin) {
      selectedIndex = 3;
    } else {
      selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = darkModeNotifier.value ? Colors.white : Colors.black87;
    final Color appBarColor = darkModeNotifier.value ? Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Request Handle', style: TextStyle(color: textColor)),
        backgroundColor: appBarColor,
        elevation: 2,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          _NavigationButtons(
            onSectionChange: _changeSection,
            selectedIndex: selectedIndex,
          ),

          selectedIndex == 0
              ? Expanded(child: RequestHandlePage())
              : selectedIndex == 1
              ? Expanded(child: AdminListWidget()) //
              : selectedIndex == 2
              ? Expanded(child: FeedbackViewPage())
              : selectedIndex ==3 ?
                Expanded(child: TeamPinsDashboard())
              : Expanded(child: SchoolStatsPage()),

        ],
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final Function(int) onSectionChange;
  final int selectedIndex;

  const _NavigationButtons({
    Key? key,
    required this.onSectionChange,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = darkModeNotifier.value ? Colors.white : Colors.black87;

    return SizedBox(
      height: 65,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (globalUser.isSuperUser)
            _buildTextButton("See Requests", 0, textColor),
            if (globalUser.isSuperUser)
            _buildTextButton("See Admins", 1, textColor),
            if (globalUser.isSuperUser)
            _buildTextButton("See Feedback", 2, textColor),
            if (globalUser.isUpperAdmin)
            _buildTextButton("Pins Page", 3, textColor),
            if (globalUser.isSuperUser)
            _buildTextButton("User Stats", 4, textColor),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );

  }

  Widget _buildTextButton(String text, int index, Color textColor) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        onSectionChange(index);
      },
      child: Row(
        children: [
          SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  color: isSelected ? Colors.blue : textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              SizedBox(height: 3),
              if (isSelected)
                Container(
                  width: 60,
                  height: 3,
                  color: Colors.blue,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
