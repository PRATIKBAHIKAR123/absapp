import 'dart:convert';

import 'package:abs/global/styles.dart';
import 'package:abs/screens/dashboard/dashboard.dart';
import 'package:abs/screens/login/login-options.dart';
import 'package:abs/services/loginService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AbsAppBar({super.key});

  @override
  _AbsAppBarState createState() => _AbsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AbsAppBarState extends State<AbsAppBar> {
  // List<String> userList = [];

  // @override
  // void initState() {
  //   super.initState();
  //   getuserList();
  // }

  // Future<void> getuserList() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   userList = prefs.getStringList('userList') ?? [];
  //   print(userList);
  // }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: Image.asset(
          'assets/icons/drawer.png',
          height: 29,
          width: 29,
        ),
      ),
      title: Image.asset('assets/images/abs-logo.png',
          height: 40), // Replace with your logo
      centerTitle: true,
      shadowColor: abs_grey,
      backgroundColor: Colors.white,
      elevation: 4.0,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 10),
          child: CircleAvatarDropdown(),
        ),
      ],
    );
  }
}

class CircleAvatarDropdown extends StatefulWidget {
  const CircleAvatarDropdown({super.key});

  @override
  _CircleAvatarDropdownState createState() => _CircleAvatarDropdownState();
}

class _CircleAvatarDropdownState extends State<CircleAvatarDropdown> {
  final TextStyle usersTextStyle = GoogleFonts.karla(
    color: const Color.fromRGBO(130, 130, 130, 1),
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  bool isLoading = false;

  List<Map<String, dynamic>> userList = [];
  late Map<String, dynamic> loggedInUser;

  @override
  void initState() {
    super.initState();
    getUserList();
  }

  Future<void> getUserList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? userListJson = prefs.getStringList('userList');
    String? userDataString = prefs.getString('userData');
    loggedInUser = jsonDecode(userDataString!);
    if (loggedInUser != null) {
      print('loggedInUser$loggedInUser');
    }
    if (userListJson != null) {
      setState(() {
        try {
          userList = userListJson
              .map<Map<String, dynamic>>((jsonString) =>
                  jsonDecode(jsonString) as Map<String, dynamic>)
              .toList();
        } catch (e) {
          print('Error decoding user list: $e');
          userList = [];
        }
      });
      print('User list: $userList');
    } else {
      print('User list is null or empty');
    }
  }

  login(context, user) async {
    setState(() {
      isLoading = true;
    });

    try {
      var response = await loginService(user);

      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', data);
        String? userId = decodedData['user']['user_ID']?.toString();
        if (decodedData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login Success"),
            ),
          );
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

  logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginOptions(
                title: 'LogOut',
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loggedIninitial = loggedInUser['user']['first_Name'][0].toUpperCase();
    final company_name = loggedInUser['company']['compName'];
    return PopupMenuButton<int>(
      child: Column(children: [
        CircleAvatar(
          radius: 20,
          child: Text(loggedIninitial),
        ),
        SizedBox(
          height: 2,
        ),
        Badge(
          largeSize: 10,
          smallSize: 20,
          padding: EdgeInsets.all(2),
          backgroundColor: abs_blue,
          alignment: Alignment.center,
          label: Text(
            company_name,
            style: TextStyle(fontSize: 5),
          ),
        ),
      ]),
      itemBuilder: (context) => [
        ...userList.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final initials = user['first_Name'][0].toUpperCase();

          Color avatarColor;
          if (index % 3 == 0) {
            avatarColor = Colors.blue;
          } else if (index % 3 == 1) {
            avatarColor = Colors.red;
          } else {
            avatarColor = Colors.green;
          }

          return PopupMenuItem<int>(
            padding: EdgeInsets.all(5),
            value: index,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarColor,
                  child: Text(
                    initials,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Badge(
                      backgroundColor: avatarColor,
                      alignment: Alignment.centerLeft,
                      label: Text(user['company_name']),
                    ),
                    Text(user['userName'], style: usersTextStyle)
                  ],
                ),
              ],
            ),
          );
        }),
        PopupMenuDivider(),
        PopupMenuItem<int>(
          value: -1,
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.black),
              const SizedBox(width: 10),
              Text('Log Out', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == -1) {
          logOut();
        } else {
          login(context, userList[value]);
        }
      },
    );
  }
}
