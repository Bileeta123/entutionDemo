// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async => _database ??= await _initDB();

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    final String response =
        await rootBundle.loadString('assets/app_config.json');
    final data = jsonDecode(response);
    for (var app in data['apps']) {
      for (var table in app['database']['tables']) {
        String sql = 'CREATE TABLE ${table['tableName']} (';
        for (var column in table['columns']) {
          sql += '${column['columnName']} ${column['dataType']}, ';
        }
        sql = sql.substring(0, sql.length - 2) + ');';
        await db.execute(sql);
      }
    }
  }

  Future<void> insert(
      String appId, String formId, Map<String, dynamic> formData) async {
    final db = await database;
    String table = getTableName(appId, formId);
    await db.insert(table, formData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  String getTableName(String appId, String formId) {
    // Example logic to map appId and formId to a tableName
    switch (appId) {
      case "selfcare":
        if (formId == "addNewMemberForm") return "members";
        if (formId == "addMemberDetailsForm") return "details";
        break;
      case "farmer":
        if (formId == "addNewFarmerForm") return "farmers";
        break;
      // Add more cases as needed
    }
    throw Exception(
        'Table name mapping not found for appId: $appId and formId: $formId');
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [data['id']]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> fetchDropdownOptions(String query) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.rawQuery(query);
      return results;
    } catch (e) {
      print('Error fetching options from database: $e');
      return [];
    }
  }

  executeJoinOperation(String appId, String s) {}
}
