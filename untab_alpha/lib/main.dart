import 'package:flutter/material.dart';
import 'package:untab_alpha/pages/login.dart';
import 'package:untab_alpha/pages/signup.dart';
import 'package:untab_alpha/pages/widgets/custom_bottom_nav.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'unTab',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/login': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/home': (context) => const CustomBottomNav(),
      },
    );
  }
}
