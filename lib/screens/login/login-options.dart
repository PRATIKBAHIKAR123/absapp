import 'package:abs/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pwa_install/pwa_install.dart';

class LoginOptions extends StatefulWidget {
  const LoginOptions({super.key, required this.title});

  final String title;

  @override
  State<LoginOptions> createState() => _LoginOptions();
}

class _LoginOptions extends State<LoginOptions> {
  final TextStyle urbanistTextStyle = GoogleFonts.urbanist(
    fontSize: 30,
    color: Colors.white,
    fontWeight: FontWeight.w700,
  );

  final TextStyle loginOptionsTextStyle = GoogleFonts.urbanist(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Container with Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/abs-img.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Logo Positioned on Top
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
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 78,
                    width: 280,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Please select your login method',
                        style: urbanistTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Horizontal Row for Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // First Button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 153,
                          height: 160,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/teacher4.png',
                                height: 67,
                                width: 67,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Login As Customer',
                                style: loginOptionsTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Second Button
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Container(
                          width: 153,
                          height: 160,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/students4.png',
                                height: 67,
                                width: 67,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Login As Admin',
                                style: loginOptionsTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Row(
              children: [
                if (PWAInstall().installPromptEnabled)
                  ElevatedButton(
                      onPressed: () {
                        try {
                          PWAInstall().promptInstall_();
                        } catch (e) {
                          setState(() {
                            //error = e.toString();
                          });
                        }
                      },
                      child: const Text('Install App')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
