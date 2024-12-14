import 'package:flutter/material.dart';

class CurvNavigationScreen extends StatefulWidget {
  const CurvNavigationScreen({super.key});

  @override
  _CurvNavigationScreenState createState() => _CurvNavigationScreenState();
}

class _CurvNavigationScreenState extends State<CurvNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const SizedBox(
          height: 80,
        ),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Container(
        //     height: 0,
        //     decoration: const BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(30),
        //         topRight: Radius.circular(30),
        //       ),
        //     ),
        //   ),
        // ),
        ClipPath(
          clipper: CurvedBottomNavigationBarClipper(),
          child: Container(
            height: 100,
            color: Colors.orange,
          ),
        ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.transparent,
            elevation: 0,
            onTap: _onItemTapped,
          ),
        ),
        Positioned(
          top: 20,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: FloatingActionButton(
            onPressed: () {
              // Define action
            },
            backgroundColor: Colors.red,
            elevation: 2,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class CurvedBottomNavigationBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 30);
    path.quadraticBezierTo(size.width / 2, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
