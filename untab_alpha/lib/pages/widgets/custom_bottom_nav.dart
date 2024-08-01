import 'package:flutter/material.dart';
import 'package:untab_alpha/pages/logged_in/emergency_contacts.dart';
import 'package:untab_alpha/pages/logged_in/homepage.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int currentPage = 0;
  final List<Widget> screens = const [
    Homepage(),
    EmergencyContacts(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Contacts'),
        ],
      ),
    );
  }
}