import 'dart:convert';
import 'package:http/http.dart' as http;

Future<http.Response> setupInfoService(Map<String, dynamic> jsonBody) async {
  var url = 'https://erpapi.abssoftware.in/api/Invoice/SetupInfo';
  var client = http.Client();
  http.Response? response;

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
    print('Error in setupInfoService: $e');
  } finally {
    client.close();
  }

  return response ??
      http.Response('{}',
          500); // Return an empty response with status 500 if an error occurs
}

Future<Map<String, dynamic>> getSetupInfoData(
    invtype, fromInvoice, currentSessionId) async {
  try {
    var requestBody = {
      "fromInvoice": fromInvoice,
      "sessionId": currentSessionId,
      "invtype": invtype,
    };

    var response = await setupInfoService(requestBody);

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      return decodedData;
    } else {
      print('Error: Received status code ${response.statusCode}');
    }
  } catch (e) {
    print('Error in getSetupInfoData: $e');
  }

  return {}; // Return an empty map if an error occurs
}
