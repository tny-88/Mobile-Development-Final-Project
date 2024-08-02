import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:untab_alpha/pages/logged_in/emergency_contacts.dart';
import 'package:untab_alpha/pages/logged_in/homepage.dart';
import 'package:untab_alpha/pages/logged_in/profile.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'unTab',
    'Check which medicine to take today',
    tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5)),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel_id', 
        'Reminders', 
        channelDescription: 'Notification channel for app reminders', 
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );


  Future.delayed(const Duration(hours: 2), scheduleNotification);
}

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 0;
  final List<Widget> screens = [
    const Homepage(),
    const EmergencyContacts(),
    const Profile()
  ];

  @override
  void initState() {
    super.initState();
    scheduleNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.medical_information), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
