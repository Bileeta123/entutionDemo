import 'package:flutter/material.dart';
import 'package:entutiondemoapp/form_screen.dart';

class SelfcareHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Form'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormScreen(
                        appId: "selfcare", formId: "addNewMemberForm"),
                  ),
                );
              },
              child: Text('Form 1: Add New Member'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormScreen(
                        appId: "selfcare", formId: "addMemberDetailsForm"),
                  ),
                );
              },
              child: Text('Form 2: Add Member Details'),
            ),
          ],
        ),
      ),
    );
  }
}
