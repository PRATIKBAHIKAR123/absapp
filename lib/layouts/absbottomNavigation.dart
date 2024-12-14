import 'package:abs/screens/dashboard/dashboard.dart';
import 'package:abs/screens/register/registerListScreen.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  int? businessTypeId;

  @override
  void initState() {
    super.initState();
    getCompanyData();
  }

  Future<void> getCompanyData() async {
    Map<String, dynamic>? currentCompany =
        await CompanyDataUtil.getCompanyFromLocalStorage();
    setState(() {
      businessTypeId = currentCompany!['businessType'];
    });
    print('businessTypeId$businessTypeId');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print('_selectedIndex$_selectedIndex');
    switch (_selectedIndex) {
      case 0:
        return setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        });
      case 1:
        return setState(() {
          if (businessTypeId == 27) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RegisterListScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        });
      case 2:
        return setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/Home.png',
            height: 24,
            width: 24,
            color: _selectedIndex == 0 ? Colors.blue : Colors.black,
          ),
          label: '',
        ),
        if (businessTypeId == 27) ...[
          BottomNavigationBarItem(
            icon: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/icons/doc.png',
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
            label: '',
          )
        ],
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/icons/Notification.png',
            height: 24,
            width: 24,
            color: _selectedIndex == 2 ? Colors.blue : Colors.black,
          ),
          label: '',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.white,
      elevation: 10,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    );
  }
}
