import 'package:entutiondemoapp/FarmingPlotCreate.dart';
import 'package:entutiondemoapp/FormBuilderScreen.dart';
import 'package:entutiondemoapp/DatabaseHelper.dart';
import 'package:flutter/material.dart';

class FarmerHomeScreen extends StatefulWidget {
  final String appName;
  final String screenName;

  const FarmerHomeScreen(
      {super.key, required this.appName, required this.screenName});
  // const FormBuilderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FarmerHomeScreen createState() => _FarmerHomeScreen();
}

class _FarmerHomeScreen extends State<FarmerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Form'),
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
                    builder: (context) => AddFarmingPlotScreen(),
                  ),
                );
              },
              child: Text('Form 1: Add Farming Plot'),
            ),
          ],
        ),
      ),
    );
  }
}
