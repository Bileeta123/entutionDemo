// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:entutiondemoapp/apiService.dart';
import 'package:entutiondemoapp/sqlService.dart';
import 'package:entutiondemoapp/sqliteHelper.dart';
import 'package:entutiondemoapp/storageService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:entutiondemoapp/Structure.json';

class FormBuilderScreen extends StatefulWidget {
  final String appName;
  final String screenName;
  final int appId;

  const FormBuilderScreen(
      {super.key,
      required this.appName,
      required this.screenName,
      required this.appId});
  // const FormBuilderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FormBuilderScreenState createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  final dynamic jsonData = {
    "apps": [
      {
        "appName": "Selfcare",
        "screens": [
          {
            "screenName": "Add New Member",
            "formTable": "users",
            "forms": [
              {
                "formName": "Add New Member",
                "fields": [
                  {
                    "fieldName": "Selfcare First Name",
                    "type": "text",
                    "placeholder": "Enter your first name",
                    "dbMapper": "fName",
                    "sequence": 1
                  },
                  {
                    "fieldName": "Last Name",
                    "type": "text",
                    "placeholder": "Enter your last name",
                    "dbMapper": "lName",
                    "sequence": 2
                  },
                  {
                    "fieldName": "Gender",
                    "type": "dropdown",
                    "options": ["Male", "Female", "Other"],
                    "placeholder": "Select your gender",
                    "dbMapper": "gender",
                    "sequence": 3
                  },
                  {
                    "fieldName": "Phone Number",
                    "type": "number",
                    "placeholder": "Enter your phone number",
                    "sequence": 4,
                    "dbMapper": "pNumber",
                    "validation": {
                      "regex": "^\\+?\\d{10,15}",
                      "errorText": "Invalid phone number"
                    }
                  }
                ],
              }
            ]
          }
        ],
        "database": [
          {
            "tableName": "products",
            "columns": [
              {
                "columnName": "id",
                "dataType": "INTEGER PRIMARY KEY AUTOINCREMENT"
              },
              {"columnName": "name", "dataType": "TEXT NOT NULL"},
              {"columnName": "price", "dataType": "REAL NOT NULL"}
            ]
          },
          {
            "tableName": "users",
            "columns": [
              {
                "columnName": "id",
                "dataType": "INTEGER PRIMARY KEY AUTOINCREMENT"
              },
              {"columnName": "name", "dataType": "TEXT NOT NULL"},
              {"columnName": "email", "dataType": "TEXT NOT NULL UNIQUE"}
            ]
          }
        ],
        "actions": [
          {
            "actionName": "save",
            "actionTable": [
              {
                "tableName": "users",
                "dbMapper": {"name": "fName", "email": "lName"}
              }
            ]
          }
        ]
      },
      {
        "appName": "Farmer",
        "screens": [
          {
            "screenName": "Add New Farmer",
            "forms": [
              {
                "formName": "Add New Farmer",
                "fields": [
                  {
                    "fieldName": "Farmer First Name",
                    "type": "text",
                    "placeholder": "Enter your first name",
                    "sequence": 1
                  },
                  {
                    "fieldName": "Last Name",
                    "type": "text",
                    "placeholder": "Enter your last name",
                    "sequence": 2
                  },
                  {
                    "fieldName": "Gender",
                    "type": "dropdown",
                    "options": ["Male", "Female", "Other"],
                    "placeholder": "Select your gender",
                    "sequence": 3
                  },
                  {
                    "fieldName": "Crop",
                    "type": "dropdown",
                    "options": ["Carrot", "Cabbage", "Broccoli"],
                    "placeholder": "Select the Crop",
                    "sequence": 3
                  }
                ]
              }
            ]
          }
        ],
        "database": [
          {
            "tableName": "products",
            "columns": [
              {
                "columnName": "id",
                "dataType": "INTEGER PRIMARY KEY AUTOINCREMENT"
              },
              {"columnName": "name", "dataType": "TEXT NOT NULL"},
              {"columnName": "price", "dataType": "REAL NOT NULL"}
            ]
          },
          {
            "tableName": "users",
            "columns": [
              {
                "columnName": "id",
                "dataType": "INTEGER PRIMARY KEY AUTOINCREMENT"
              },
              {"columnName": "name", "dataType": "TEXT NOT NULL"},
              {"columnName": "email", "dataType": "TEXT NOT NULL UNIQUE"}
            ]
          }
        ],
        "actions": [
          {
            "actionName": "save",
            "actionTable": [
              {
                "tableName": "user",
                "dbMapper": {"name": "fName", "email": "lName"}
              }
            ]
          }
        ]
      }
    ]
  };

  final _formKey = GlobalKey<FormState>();
  var _isInit = true;
  final Map<String, dynamic> _formData = {};

  List<dynamic> formFields = [];
  List<dynamic> jsonData11 = [];

  List<dynamic> _getFormFields() {
    var appData = jsonData['apps'].firstWhere(
      (app) => app['appName'] == widget.appName,
    );
    // var appData = data?['apps'].firstWhere(
    // (app) => app['appName'] == widget.appName,
    // );

    // if (appData.isNotEmpty && appData.containsKey('screens')) {
    //   var fields = appData['screens'][0]['forms'][0]['fields'];
    //   if (fields is List) {
    //     return fields;
    //   }
    // }

    // Find the screen with the screenName passed to the widget.
    var screenData = appData['screens'].firstWhere(
      (screen) => screen['screenName'] == widget.screenName,
    );

    if (screenData.isNotEmpty && screenData.containsKey('forms')) {
      // Assuming each screen has only one form for simplicity.
      var fields = screenData['forms'][0]['fields'];
      if (fields is List) {
        return fields;
      }
    }

    return [];
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      //Get relavent app's object
      var appData = jsonData['apps'].firstWhere(
        (app) => app['appName'] == widget.appName,
      );

      //Get relavent screen's object
      var screenData = appData['screens'].firstWhere(
        (screen) => screen['screenName'] == widget.screenName,
      );

      //Get relavent action's object according to the actionName
      var actionData =
          appData['actions'].firstWhere((app) => app['actionName'] == "save");

      //Get objects with the same actionTable and screentable
      var actionTableData = actionData['actionTable']
          .firstWhere((app) => app['tableName'] == screenData['formTable']);

      //insert
      var dbHelper = SQFliteDBHelper('selfcare.db');
      await dbHelper.insertFormData(dbHelper, actionTableData, _formData);
      // print('Form Data: $_formData');
    }
  }

  DynamicDBHelper dbHelper = DynamicDBHelper();
  Map<String, dynamic>? data = {};
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      // data = await ApiService().fetchData(widget.appId);
      // print(data);
      setState(() {
        formFields = _getFormFields();
      });
      formFields.sort((a, b) => a['sequence'].compareTo(b['sequence']));
      DynamicDBHelper.createTablesFromJson();
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    // test();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              ...formFields.map((field) {
                switch (field['type']) {
                  case 'text':
                    return TextFormField(
                      decoration: InputDecoration(
                        hintText: field['placeholder'],
                        labelText: field['fieldName'],
                      ),
                      onSaved: (value) {
                        _formData[field['dbMapper']] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter ${field['fieldName'].toLowerCase()}';
                        }
                        return null;
                      },
                    );
                  case 'dropdown':
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: field['fieldName'],
                      ),
                      items: field['options']
                          .map<DropdownMenuItem<String>>((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _formData[field['dbMapper']] = value;
                      },
                      onSaved: (value) {
                        _formData[field['dbMapper']] = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select ${field['fieldName'].toLowerCase()}';
                        }
                        return null;
                      },
                      hint: Text(field['placeholder']),
                    );
                  case 'number':
                    return TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: field['placeholder'],
                        labelText: field['fieldName'],
                      ),
                      onSaved: (value) {
                        _formData[field['dbMapper']] = value;
                      },
                      validator: (value) {
                        String apiRegex = field['validation']['regex'];
                        final regex = RegExp(apiRegex);

                        if (value == null || value.isEmpty) {
                          return 'Please enter ${field['fieldName'].toLowerCase()}';
                        } else if (!regex.hasMatch(value)) {
                          return field['validation']['errorText'];
                        }

                        return null;
                      },
                    );
                  default:
                    return Container();
                }
              }),
              const SizedBox(height: 20), // Add some space before the button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
