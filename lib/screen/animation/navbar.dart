import 'package:chewlinboard/main.dart';
import 'package:chewlinboard/screen/application/homePage/home_page.dart';
import 'package:chewlinboard/screen/application/messagePage/message_page.dart';
import 'package:chewlinboard/screen/application/notificationPage/notification_page.dart';
import 'package:chewlinboard/screen/application/profilePage/profile_page.dart';
import 'package:chewlinboard/screen/application/projectPage/project_page.dart';
import 'package:flutter/material.dart';

//https://www.youtube.com/watch?v=VfUUOI6BUtE
class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int currentIndex = 0;
  final screens = [
    HomePage(),
    NotificationPage(),
    ProjectPage(),
    MessagePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(
              Icons.home_rounded,
              color: white,
            ),
            backgroundColor: black,
          ),
          BottomNavigationBarItem(
            label: 'Notification',
            icon: Icon(
              Icons.notifications_none_rounded,
              color: white,
            ),
            backgroundColor: black,
          ),
          BottomNavigationBarItem(
            label: 'Project',
            icon: Icon(
              Icons.folder_open_rounded,
              color: white,
            ),
            backgroundColor: black,
          ),
          BottomNavigationBarItem(
            label: 'Message',
            icon: Icon(
              Icons.send_rounded,
              color: white,
            ),
            backgroundColor: black,
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(
              Icons.skateboarding_rounded, //Icons.person
              color: white,
            ),
            backgroundColor: black,
          ),
        ],
      ),
    );
  }
}
