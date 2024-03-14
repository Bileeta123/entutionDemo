import 'dart:convert';
import 'package:entutiondemoapp/storageService.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl =
      "https://3f99-2402-d000-8120-7d71-d8fd-1498-68d4-a176.ngrok-free.app/appconfig/";

  Future<dynamic> fetchData(appId) async {
    final String baseUrl1 =
        "https://3f99-2402-d000-8120-7d71-d8fd-1498-68d4-a176.ngrok-free.app/appconfig?app_id=$appId";
    final response = await http.get(Uri.parse(baseUrl1));
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> map = jsonDecode(response.body);
      // await LocalStorageService()
      //     .saveJsonObject('AppData', jsonDecode(response.body));
      return map;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
