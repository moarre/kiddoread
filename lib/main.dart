import 'package:flutter/material.dart';
import 'package:ohsem/pages/profile_screen.dart';
import 'package:ohsem/pages/update_profile_screen.dart';
import 'authentication/login_page.dart';
import 'authentication/registration_page.dart';
import 'home_page.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => const ProfileScreen(),
        '/updateprofile': (context) => const UpdateProfileScreen(),
      },
    );
  }
}
