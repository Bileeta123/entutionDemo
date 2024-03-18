// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DatabaseHelper {
  static Database? _database;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async => _database ??= await initDB();

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    final String response =
        await rootBundle.loadString('assets/app_config.json');
    final data = json.decode(response);

    for (var app in data['apps']) {
      for (var table in app['database']['tables']) {
        String sql = 'CREATE TABLE ${table['tableName']} (';
        for (var column in table['columns']) {
          sql += '${column['columnName']} ${column['dataType']}, ';
        }
        sql = sql.substring(0, sql.length - 2) + ');'; // Remove trailing comma
        await db.execute(sql);
      }
    }
  }

  // Enhanced Insert Function
  Future<void> insert(
      String appId, String formId, Map<String, dynamic> formData) async {
    final db = await database;
    String table =
        getTableName(appId, formId); // Function to map formId to tableName
    await db.insert(table, formData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> executeJoinOperation(
      String appId, String actionId) async {
    final db = await database;
    // Load JSON configuration
    final String response =
        await rootBundle.loadString('assets/app_config.json');
    final data = json.decode(response);

    // Find the app and then the specific join action configuration
    var selectedApp = data['apps']
        .firstWhere((app) => app['appId'] == appId, orElse: () => null);
    if (selectedApp != null) {
      var action = selectedApp['actions']
          .firstWhere((a) => a['actionId'] == actionId, orElse: () => null);
      if (action != null &&
          action['type'] == 'select' &&
          action.containsKey('join')) {
        // Construct and execute the join query
        String sql = "SELECT ";
        if (action['fields'] != null) {
          sql += action['fields'].join(', ');
        } else {
          sql += "*";
        }
        sql += " FROM ${action['tableName']} ";
        sql +=
            "${action['join']['joinType']} ${action['join']['joinTable']} ON ${action['join']['on'].entries.map((e) => '${e.key} = ${e.value}').join(' AND ')}";
        return await db.rawQuery(sql);
      }
    }
    return [];
  }

  // Function to map formId to tableName based on your application's logic
  String getTableName(String appId, String formId) {
    // Implement your logic to determine the table name based on appId and formId
    // This is an example, modify it as per your JSON and application structure
    if (appId == "selfcare" && formId == "addNewMemberForm") return "members";
    if (appId == "selfcare" && formId == "addMemberDetailsForm")
      return "details";
    if (appId == "farmer" && formId == "addNewFarmerForm") return "farmers";
    // Add more conditions as necessary
    return ""; // Return a default or throw an error as needed
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db
        .update(table, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> fetchDropdownOptions(
      String query, String queryValue) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.rawQuery(query);
      print(results);
      List<String> options =
          results.map((row) => row[queryValue].toString()).toList();
      return options;
    } catch (e) {
      print('Error fetching options from database: $e');
      return [];
    } finally {}
  }
}
