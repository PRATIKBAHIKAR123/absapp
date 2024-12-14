import 'dart:convert';
import 'package:abs/services/sessionCheckService.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String url = 'https://erpapi.abssoftware.in/api/Auth/Login';

Future<http.Response> ledgerSyncService() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataString = prefs.getString('userData');
  Map<String, dynamic> userData = jsonDecode(userDataString!);
  String? currentSessionId = userData['user']['currentSessionId'];
  isValidSession();
  var requestBody = {
    "isSync": true,
    "lastModifiedDate": null,
    "sessionId": currentSessionId
  };
  var url = 'https://erpapi.abssoftware.in/api/Ledger/Sync';
  var client = http.Client();
  var response;

  try {
    response = await client
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 50));
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return response!;
}

ledgerSync() async {
  try {
    var response = await ledgerSyncService();

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> ledgerList = data['list'];

      List<String> stringList =
          ledgerList.map((item) => jsonEncode(item)).toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('ledger-list', stringList);
    } else {}
  } catch (e) {
    print('Error: $e');
  }
}

Future<http.Response> itemSyncService() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataString = prefs.getString('userData');
  Map<String, dynamic> userData = jsonDecode(userDataString!);
  String? currentSessionId = userData['user']['currentSessionId'];
  isValidSession();
  var requestBody = {
    "isSync": true,
    "lastModifiedDate": null,
    "sessionId": currentSessionId
  };
  var url = 'https://erpapi.abssoftware.in/api/Item/Sync';
  var client = http.Client();
  var response;

  try {
    response = await client
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 50));
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return response!;
}

itemSync() async {
  try {
    var response = await itemSyncService();

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> ledgerList = data['list'];

      List<String> stringList =
          ledgerList.map((item) => jsonEncode(item)).toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('item-list', stringList);
    } else {}
  } catch (e) {
    print('Error: $e');
  }
}

Future<http.Response> groupSyncService() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userDataString = prefs.getString('userData');
  Map<String, dynamic> userData = jsonDecode(userDataString!);
  String? currentSessionId = userData['user']['currentSessionId'];
  isValidSession();
  var requestBody = {
    "isSync": true,
    "lastModifiedDate": null,
    "sessionId": currentSessionId
  };
  var url = 'https://erpapi.abssoftware.in/api/group/Sync';
  var client = http.Client();
  var response;

  try {
    response = await client
        .post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 50));
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }

  return response!;
}

groupSync() async {
  try {
    var response = await groupSyncService();

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> ledgerList = data['list'];

      List<String> stringList =
          ledgerList.map((item) => jsonEncode(item)).toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('group-list', stringList);
    } else {}
  } catch (e) {
    print('Error: $e');
  }
}
