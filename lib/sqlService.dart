import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DynamicDBHelper {
  //  static Database? db;
  // static const String DB_NAME = 'nelnafarmer.db';
  // static String? path;

  // Future<Database> get database async {
  // if (db != null) {
  //   return db!;
  // }
  // db = await initDatabase();
  // return db!;

  // return sql.openDatabase(
  //   'nelnafarmer.db',
  //   version: 1,
  //   onCreate: (sql.Database database, int version) async {
  //     await createTables(database);
  //   },
  // );
  // }

  // initDatabase() async {
  //   io.Directory documentDirectory = await getApplicationDocumentsDirectory();
  //   path = join(documentDirectory.path, DB_NAME);
  //   var db = await openDatabase(path!, version: 1,
  //       onCreate: (sql.Database database, int version) async {
  //     await createTables(database);
  //   });
  //   //print('heree');
  //   return db;
  // }
  // Parse JSON and create tables dynamically
  // static Future<void> createTablesFromJson(String jsonString) async {
  static Future<void> createTablesFromJson() async {
    // final dynamic json = jsonDecode(jsonString);
    final dynamic json = {
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
                }
              ]
            }
          ]
        }
      ],
      "database": [
        {
          "dbName": "FarmingCyle",
          "columns": [
            {"columnName": "id"},
            {"columnName": "cycleId"},
            {"columnName": "CycleName"}
          ]
        }
      ]
    };

    // Extract database name (assuming only one database in JSON)
    final String dbName = json['database'][0]['dbName'];
    final List<dynamic> columns = json['database'][0]['columns'];

    // Database path
    String path = join(await getDatabasesPath(), '$dbName.db');

    // Open the database, creating it if it doesn't exist
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Build SQL command for table creation
        String sql = 'CREATE TABLE IF NOT EXISTS $dbName (';
        for (var column in columns) {
          // Assuming all columns are of type TEXT for simplicity
          // Adjust this logic to handle different data types as necessary
          String columnName = column['columnName'];
          sql += '$columnName TEXT NOT NULL,';
        }
        sql = sql.substring(0, sql.length - 1); // Remove last comma
        sql += ');';

        // Execute the CREATE TABLE statement
        await db.execute(sql);
      },
    );

    // Close the database
    await db.close();
  }
}
