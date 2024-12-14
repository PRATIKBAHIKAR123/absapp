import 'dart:convert';
import 'package:abs/services/sessionCheckService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String url = 'https://erpapi.abssoftware.in/api/Auth/Login';

Future<http.Response> getSalesPersonService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Salesman/GetById'; // Replace with your actual login API URL
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

Future<http.Response> getInvoicePdf(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpprint.abssoftware.in/api/Print/PrintInvoice'; // Replace with your actual login API URL
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
