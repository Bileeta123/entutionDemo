import 'dart:convert';

import 'package:entutiondemoapp/FormBuilderScreen.dart';
import 'package:entutiondemoapp/Schemas/TableSchema.dart';
import 'package:entutiondemoapp/sqliteHelper.dart';
// import 'package:entutiondemoapp/Farmer/HomeScreen.dart' as FarmerHomeScreen;
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final dynamic jsonData = {
    "apps": [
      {
        "appName": "Selfcare",
        "screens": [
          {
            "screenName": "Add New Member",
            "forms": [
              {
                "formName": "Add New Member",
                "fields": [
                  {
                    "fieldName": "Selfcare First Name",
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
                    "fieldName": "Phone Number",
                    "type": "number",
                    "placeholder": "Enter your phone number",
                    "sequence": 4,
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
            "dbName": "selfcareTest",
            "columns": [
              {"columnName": "id"},
              {"columnName": "cycleId"},
              {"columnName": "CycleName"}
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
            "dbName": "farmingCycle",
            "columns": [
              {"columnName": "id"},
              {"columnName": "cycleId"},
              {"columnName": "CycleName"}
            ]
          }
        ]
      }
    ]
  };

  Future<List<TableSchema>> fetchTableSchemas() async {
    // Simulating a network request. Replace this with your actual API call.
    var response = '''[
    {
      "tableName": "users",
      "columns": [
        {"columnName": "id", "dataType": "INTEGER PRIMARY KEY AUTOINCREMENT"},
        {"columnName": "name", "dataType": "TEXT NOT NULL"},
        {"columnName": "email", "dataType": "TEXT NOT NULL UNIQUE"}
      ]
    },
    {
      "tableName": "products",
      "columns": [
        {"columnName": "id", "dataType": "INTEGER PRIMARY KEY AUTOINCREMENT"},
        {"columnName": "name", "dataType": "TEXT NOT NULL"},
        {"columnName": "price", "dataType": "REAL NOT NULL"}
      ]
    }
  ]''';

    final jsonData = jsonDecode(response) as List;
    return jsonData.map((json) => TableSchema.fromJson(json)).toList();
  }

  createCustomTables(database) async {
    // var selcareDbHelper = SQFliteDBHelper(database);

    // selcareDbHelper.createProductTable(selcareDbHelper);
    // selcareDbHelper.insertProduct(selcareDbHelper, 'Playstation', 1000000.99);

    var dbHelper = SQFliteDBHelper(database);
    List<TableSchema> schemas = await fetchTableSchemas();

    for (var schema in schemas) {
      // print(schema.columns);
      await dbHelper.createTableFromSchema(schema);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: <Widget>[
          Card(
            child: InkWell(
              onTap: () {
                createCustomTables('selfcare.db');
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FormBuilderScreen(
                    appName: 'Selfcare',
                    screenName: 'Add New Member',
                    appId: 1,
                  ),
                ));
              },
              child: const Center(
                child: Text('Selfcare'),
              ),
            ),
          ),
          Card(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FormBuilderScreen(
                    appName: 'Farmer',
                    screenName: 'Add New Farmer',
                    appId: 2,
                  ),
                ));
              },
              child: const Center(
                child: Text('Farmer'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
