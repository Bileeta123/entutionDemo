// ignore_for_file: avoid_print

import 'package:entutiondemoapp/DatabaseHelper.dart';

class DynamicFunctionHandler {
  final Map<String, Function> functionMap = {};

  DynamicFunctionHandler() {
    // Now in the constructor body, we can access instance members
    functionMap['getUOMGroupDetails'] = getUOMGroupDetails;
    // Add more functions as needed
  }

  Future<List<String>> getUOMGroupDetails(
      String functionName, String functionQuery, String queryValue) async {
    print("getUOMGroupDetails function called");
    List<String> options = await DatabaseHelper.instance
        .fetchDropdownOptions(functionQuery, queryValue);
    print(options);
    return options;
  }

  Future<List<String>> callFunctionByName(
      String functionName, String functionQuery, String queryValue) {
    if (functionMap.containsKey(functionName)) {
      var functionToCall = functionMap[functionName];
      if (functionToCall != null) {
        var temp = functionToCall(functionName, functionQuery, queryValue);
        return temp;
      }
      return Future.error("Function $functionName found, but it's null.");
    } else {
      print("Function $functionName not found.");
      return Future.error("Function $functionName found, but it's null111.");
    }
  }
}
