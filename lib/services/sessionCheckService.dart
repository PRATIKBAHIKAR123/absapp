import 'dart:convert';
import 'package:abs/services/navigationservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<bool> checkSessionService() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataString = prefs.getString('userData');

  if (userDataString == null) {
    print('No user data found in shared preferences.');
    return false;
  }

  Map<String, dynamic> userData;
  try {
    userData = jsonDecode(userDataString);
  } catch (e) {
    print('Error decoding user data: $e');
    return false;
  }

  String? currentSessionId = userData['user']['currentSessionId'];
  if (currentSessionId == null) {
    print('No current session ID found in user data.');
    return false;
  }

  var url = 'https://erpapi.abssoftware.in/api/Auth/CheckSession';
  var client = http.Client();
  var response;

  try {
    response = await client
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"id": 0, "sessionId": currentSessionId}),
        )
        .timeout(const Duration(seconds: 50));

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      if (responseBody == true) {
        return true;
      } else {
        print('Invalid session response: $responseBody');
      }
    } else {
      print('Failed to check session. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return false;
}

Future<void> isValidSession() async {
  if (await checkSessionService() == false) {
    navigationService.navigateTo('/login');
  }
}
