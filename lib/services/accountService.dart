import 'dart:convert';
import 'package:abs/services/sessionCheckService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String url = 'https://erpapi.abssoftware.in/api/Auth/Login';

Future<http.Response> accountListService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Voucher/Search'; // Replace with your actual login API URL
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

Future<http.Response> getVoucherDetails(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Voucher/GetById'; // Replace with your actual login API URL
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

Future<http.Response> createVoucherService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Voucher/Create'; // Replace with your actual login API URL
  var client = http.Client();
  var response;

  try {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode(jsonBody);
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    response = await http.Response.fromStream(streamedResponse);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Response headers: ${response.headers}');
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to get response from server');
  } finally {
    client.close();
  }

  if (response == null) {
    throw Exception('Failed to get response from server');
  }

  return response!;
}

Future<http.Response> updateVoucherService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Voucher/Update'; // Replace with your actual login API URL
  var client = http.Client();
  var response;

  try {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode(jsonBody);
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    response = await http.Response.fromStream(streamedResponse);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Response headers: ${response.headers}');
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to get response from server');
  } finally {
    client.close();
  }

  if (response == null) {
    throw Exception('Failed to get response from server');
  }

  return response!;
}
