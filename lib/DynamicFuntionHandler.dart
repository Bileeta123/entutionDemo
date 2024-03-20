import 'package:entutiondemoapp/DatabaseHelper.dart';

class DynamicFunctionHandler {
  // Maps function names to their implementations
  final Map<String, Future<List<Map<String, dynamic>>> Function(String)>
      functionMap = {};

  DynamicFunctionHandler() {
    functionMap['getUOMGroupDetails'] = getUOMGroupDetails;
  }

  Future<List<Map<String, dynamic>>> getUOMGroupDetails(String query) async {
    print("Function getUOMGroupDetails called with query: $query");
    return await DatabaseHelper.instance.fetchDropdownOptions(query);
  }

  Future<List<Map<String, dynamic>>> callFunctionByName(
      String functionName, String query) async {
    if (functionName == 'getUOMGroupDetails') {
      return getUOMGroupDetails(query);
    } else {
      print("Function $functionName not found.");
      return [];
    }
  }
}
