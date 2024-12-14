import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CompanyDataUtil {
  static Future<Map<String, dynamic>?> getCompanyFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        return userData['company'];
      } catch (e) {
        print('Error parsing userData JSON: $e');
        return null;
      }
    } else {
      print('No userData found in SharedPreferences');
      return null;
    }
  }
}
