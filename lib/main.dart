import 'package:abs/global/styles.dart';
import 'package:abs/screens/dashboard/dashboard.dart';
import 'package:abs/screens/login/login-options.dart';
import 'package:abs/screens/login/login.dart';
import 'package:abs/services/navigationservice.dart';
import 'package:abs/services/sessionCheckService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pwa_install/pwa_install.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

void main() {
  PWAInstall().setup(installCallback: () {
    debugPrint('APP INSTALLED!');
  });
  runApp(
    MultiProvider(
      providers: [
        Provider<NavigationService>.value(value: navigationService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABS',
      routes: {
        '/login': (context) => const LoginOptions(
              title: 'Login Options',
            ),
        '/home': (context) => const DashboardScreen(),
      },
      builder: (context, child) => ResponsiveWrapper.builder(child,
          maxWidth: 1200,
          minWidth: 420,
          defaultScale: true,
          breakpoints: [
            const ResponsiveBreakpoint.resize(380, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(560, name: TABLET),
            const ResponsiveBreakpoint.autoScale(640, name: DESKTOP),
            const ResponsiveBreakpoint.autoScale(1600, name: 'XL'),
          ],
          background: Container(color: Color(0xFFF5F5F5))),
      navigatorKey: navigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: abs_blue,
        colorScheme: ColorScheme.fromSeed(
          primary: abs_blue,
          seedColor: abs_blue,
        ),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: checkSessionService(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: Image.asset(
                  'assets/images/abs-logo.png',
                  height: 200,
                  width: 200,
                ), // Adjust path as per your project structure
              ),
            ); // Or a splash screen
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            print('Session check result: ${snapshot.data}');
            return snapshot.data == true
                ? const DashboardScreen()
                : const LoginOptions(
                    title: 'Login Options',
                  );
          }
        },
      ),
    );
  }
}
