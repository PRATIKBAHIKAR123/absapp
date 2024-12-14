import 'dart:convert';
import 'package:abs/services/sessionCheckService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String url = 'https://erpapi.abssoftware.in/api/Auth/Login';

Future<http.Response> createInvoiceService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/Create'; // Replace with your actual login API URL
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

  return response!;
}

Future<http.Response> updateInvoiceService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/Update'; // Replace with your actual login API URL
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

  return response!;
}

Future<http.Response> createBillNo(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/LastBillNoCreated'; // Replace with your actual login API URL
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

Future<http.Response> getInvoiceService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/GetById'; // Replace with your actual login API URL
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

Future<http.Response> getSetupInfoService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/SetupInfo'; // Replace with your actual login API URL
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

Future<http.Response> distinctService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = 'https://erpapi.abssoftware.in/api/Common/Distinct';
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

Future<http.Response> uploadInvoiceDocService(
    Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/UploadDocument'; // Replace with your actual login API URL
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

Future<http.Response> deleteInvoiceDocService(
    Map<String, dynamic> jsonBody) async {
  //isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/DeleteDocument'; // Replace with your actual login API URL
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

Future<http.Response> dropdownService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url = 'https://erpapi.abssoftware.in/api/Common/Dropdown';
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

Future<http.Response> getInvoicePrintCode(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/PrintCode'; // Replace with your actual login API URL
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

Future<http.Response> sendEmailService(Map<String, dynamic> jsonBody) async {
  isValidSession();
  var url =
      'https://erpapi.abssoftware.in/api/Invoice/SendEmail'; // Replace with your actual login API URL
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
