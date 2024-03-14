import 'package:entutiondemoapp/FormBuilderScreen.dart';
import 'package:entutiondemoapp/DatabaseHelper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String appName;
  final String screenName;

  const HomeScreen(
      {super.key, required this.appName, required this.screenName});
  // const FormBuilderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Details'),
          onPressed: () {
            // Navigator.push(
            // context
            // MaterialPageRoute(
            //     builder: (context) => FormBuilderScreen(
            //         appName: widget.appName, screenName: widget.screenName)),
            // )
          },
        ),
      ),
    );
  }
}
