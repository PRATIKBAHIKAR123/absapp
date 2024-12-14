import 'dart:convert';

import 'package:abs/screens/dashboard/dashboard.dart';
import 'package:abs/services/loginService.dart';
import 'package:abs/services/syncService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextStyle urbanistTextStyle = GoogleFonts.urbanist(
    fontSize: 30,
    color: const Color(0xFF00AFEF),
    fontWeight: FontWeight.w700,
  );

  final TextStyle loginScreenTextStyle = GoogleFonts.urbanist(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  final TextStyle hintTextStyle = GoogleFonts.urbanist(
    fontSize: 15,
    color: const Color.fromRGBO(131, 145, 161, 1),
    fontWeight: FontWeight.w500,
  );

  final TextStyle loginbtnStyle = GoogleFonts.urbanist(
    fontSize: 15,
    color: const Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w600,
  );

  bool _obscureText = true; // State variable to control password visibility
  bool isLoading = false;

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // A key for managing the form
  final TextEditingController _name =
      TextEditingController(); // Variable to store the entered name
  final TextEditingController _password = TextEditingController();
  List<Map<String, dynamic>> _userList = [];
  late FocusNode _nameFocusNode = FocusNode();
  bool _userSuggestionsVisible = false;

  @override
  void initState() {
    super.initState();
    //_nameFocusNode = new FocusNode();
    _nameFocusNode.addListener(_onNameFieldFocusChanged);
    _loadUserList(); // Load user list when the screen initializes
  }

  void _submitForm(BuildContext context) {
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form data

      login(context);
    }
  }

  login(context) async {
    setState(() {
      isLoading = true;
    });

    try {
      var requestBody = {
        'userName': _name.text,
        'password': _password.text,
      };

      var response = await loginService(requestBody);

      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', data);
        String? userId = decodedData['user']['user_ID']?.toString();
        if (decodedData != null) {
          userList(decodedData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Success"),
            ),
          );
          ledgerSync();
          itemSync();
          groupSync();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Login"),
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid Login"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Failed"),
        ),
      );
    }
  }

  Future<void> userList(userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userList = prefs.getStringList('userList') ?? [];

    // Create a new user data map
    var newUser = {
      'userName': _name.text,
      'password': _password.text,
      'user_ID': userData['user']['user_ID']?.toString(),
      'first_Name': userData['user']['first_Name']?.toString(),
      'lastname': userData['user']['lastname']?.toString(),
      'company_name': userData['company']['compName']?.toString()
    };

    // Encode the user data to JSON string
    String newUserJson = jsonEncode(newUser);

    // Check for duplicate entry
    bool isDuplicate = userList.any((userJson) {
      var user = jsonDecode(userJson);
      return user['userName'] == newUser['userName'] ||
          user['user_ID'] == newUser['user_ID'];
    });

    if (!isDuplicate) {
      // Add the new user data to the list
      userList.add(newUserJson);

      // Save the updated list back to SharedPreferences
      await prefs.setStringList('userList', userList);

      // Retrieve and print the updated list for debugging
      userList = prefs.getStringList('userList')!;
      print('Updated userList: $userList');
    }
  }

  // Function to load user list from SharedPreferences
  Future<void> _loadUserList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userListString = prefs.getStringList('userList') ?? [];
    setState(() {
      _userList = userListString
          .map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>)
          .toList();
    });
  }

  // Function to handle selection of a user suggestion
  void _selectUserSuggestion(String username, String password) {
    _name.text = username; // Fill the username field
    _password.text = password; // Fill the password field
    _nameFocusNode.unfocus();
  }

  void _onNameFieldFocusChanged() {
    setState(() {
      // Ensure suggestions are cleared when focus is lost
      _userSuggestionsVisible = false;
    });

    if (_nameFocusNode.hasFocus) {
      setState(() {
        _userSuggestionsVisible =
            true; // Display suggestions when the name field gains focus
      });
    }
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_onNameFieldFocusChanged);
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Background Container with Image
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/abs2-img.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter),
                  ),
                ),
                // Logo Positioned on Top
                Positioned(
                  top: 56,
                  left: 22,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        height: 41,
                        width: 41,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: const Color.fromRGBO(232, 236, 244, 1)),
                            borderRadius: BorderRadius.circular(12)),
                        child: Image.asset(
                          'assets/icons/back_arrow.png',
                          width: 19,
                          height: 19,
                        ),
                      )),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 41),
                    width: 154,
                    height: 62,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/abs-logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Form(
                key: _formKey, // GlobalKey<FormState>
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      //height: 78,
                      width: 336,
                      child: Text(
                        'Welcome back! Glad to see you, Again!',
                        style: urbanistTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    AutofillGroup(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 331,
                            margin: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _name,
                              focusNode: _nameFocusNode,
                              validator: (value) {
                                // Validation function for the email field
                                if (value == null || value.isEmpty) {
                                  return 'Please enter user name.'; // Return an error message if the email is empty
                                }
                                // You can add more complex validation logic here
                                return null; // Return null if the email is valid
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 10.0),
                                hintText: 'Enter your email',
                                hintStyle: hintTextStyle,
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(247, 248, 249, 1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(
                                        232, 236, 244, 1), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(
                                        232, 236, 244, 1), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(232, 236, 244,
                                        1), // Border color when focused
                                    width: 2.0, // Border width
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_userSuggestionsVisible && _userList.isNotEmpty)
                            Container(
                              width: 336,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFF5F6FA),
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _userList.map((user) {
                                  return ListTile(
                                    title: Text(user['userName']),
                                    onTap: () {
                                      _selectUserSuggestion(
                                        user['userName'],
                                        user['password'],
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Container(
                            width: 331,
                            margin: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: _password,
                              obscureText: _obscureText,
                              validator: (value) {
                                // Validation function for the password field
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password.'; // Return an error message if the password is empty
                                }
                                // You can add more complex validation logic here
                                return null; // Return null if the password is valid
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 10.0),
                                hintText: 'Enter your password',
                                hintStyle: hintTextStyle,
                                filled: true,
                                fillColor:
                                    const Color.fromRGBO(247, 248, 249, 1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(
                                        232, 236, 244, 1), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(
                                        232, 236, 244, 1), // Border color
                                    width: 1.0, // Border width
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Color.fromRGBO(232, 236, 244,
                                        1), // Border color when focused
                                    width: 2.0, // Border width
                                  ),
                                ),
                                suffixIcon: IconButton(
                                  icon: _obscureText
                                      ? SvgPicture.asset(
                                          'assets/images/eye-show.svg', // Replace with your SVG path

                                          height: 11.38,
                                          width: 17.6,
                                        )
                                      : SvgPicture.asset(
                                          'assets/images/eye-hide.svg', // Replace with your SVG path
                                          height: 20,
                                          width: 20,
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),
                          // Second Button
                          InkWell(
                            onTap: () {
                              _submitForm(context);
                            },
                            child: Container(
                              width: 331,
                              height: 56,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 175, 239, 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Color.fromRGBO(232, 236, 244, 1),
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      textAlign: TextAlign.center,
                                      style: loginbtnStyle,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    )
                    // Horizontal Row for Buttons
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
