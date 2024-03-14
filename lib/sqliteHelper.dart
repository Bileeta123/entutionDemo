import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io' as io;
import 'dart:io';
import 'package:entutiondemoapp/Schemas/TableSchema.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SQFliteDBHelper {
  // static const _databaseName = "entution.db";
  final String _databaseName;
  final int _databaseVersion;

  SQFliteDBHelper(this._databaseName, [this._databaseVersion = 1]);

  static final Map<String, Database> _databases = {};

  Future<Database> get database async {
    if (_databases.containsKey(_databaseName)) {
      return _databases[_databaseName]!;
    }
    return await _initializeDatabase();
  }

  Future<Database> _initializeDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    Database db = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
    _databases[_databaseName] = db;
    return db;
  }

  // Empty onCreate method.
  Future _onCreate(Database db, int version) async {
    // Intentionally empty. Future table creation can be handled as needed.
  }

  Future<void> createTable(String sql) async {
    final db = await database;
    await db.execute(sql);
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  // Add methods for table creation, querying, updating, and deleting as needed.
  createProductTable(SQFliteDBHelper dbHelper) async {
    await dbHelper.createTable('''
    CREATE TABLE IF NOT EXISTS products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price REAL NOT NULL
    )
  ''');
    print('Product table created');
  }

  insertProduct(SQFliteDBHelper dbHelper, String name, double price) async {
    int id = await dbHelper.insert('products', {'name': name, 'price': price});
    print('Inserted product with id: $id');
  }

  Future<void> createTableFromSchema(TableSchema schema) async {
    final db = await database;
    String columnDefinitions = schema.columns
        .map((col) => '${col.columnName} ${col.dataType}')
        .join(', ');
    print(columnDefinitions);
    await db.execute(
        'CREATE TABLE IF NOT EXISTS ${schema.tableName} ($columnDefinitions)');

    print("Table Created");
  }

  Future<void> insertFormData(SQFliteDBHelper dbHelper, dynamic action,
      Map<String, dynamic> formData) async {
    String tableName = action['tableName'];
    Map<String, String> dbMapper = Map.from(action['dbMapper']);

    // // Mapping form data to db columns based on dbMapper
    Map<String, dynamic> row = {};
    dbMapper.forEach((dbColumn, formField) {
      if (formData.containsKey(formField)) {
        row[dbColumn] = formData[formField];
      }
    });

    // print(row);
    await dbHelper.insert(tableName, row);
    print('Inserted successfully');
  }
}
