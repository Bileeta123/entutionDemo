import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  Future<void> saveJsonObject(
      String key, Map<String, dynamic> jsonObject) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString =
        json.encode(jsonObject); // Convert JSON object to a string
    await prefs.setString(key, jsonString); // Save the JSON string
  }

  Future<Map<String, dynamic>?> loadJsonObject(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key); // Retrieve the JSON string
    if (jsonString != null) {
      return json.decode(jsonString); // Convert string back to JSON object
    }
    return null;
  }

  //   Future<void> saveJsonObject(Map<String, dynamic> jsonObject) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String jsonString = jsonEncode(jsonObject);
  //   await prefs.setString('api_json_data', jsonString);
  // }

  // Future<Map<String, dynamic>?> retrieveJsonObject() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? jsonString = prefs.getString('api_json_data');
  //   if (jsonString == null) return null;
  //   Map<String, dynamic> jsonObject = jsonDecode(jsonString);
  //   return jsonObject;
  // }

  // test() async {
  //   Map<String, dynamic>? data = await retrieveJsonObject();
  //   if (data != null) {
  //     print("Retrieved data: $data");
  //   } else {
  //     print("No saved data found.");
  //   }
  // }
}
