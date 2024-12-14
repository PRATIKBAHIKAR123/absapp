import 'dart:convert';
import 'package:abs/services/sessionCheckService.dart';
import 'package:http/http.dart' as http;

Future<http.Response> groupSearchService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Group/Search'; // Replace with your actual login API URL
  var client = http.Client();
  var response;

  try {
    response = await client
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(jsonBody),
        )
        .timeout(const Duration(seconds: 50));
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return response!;
}
