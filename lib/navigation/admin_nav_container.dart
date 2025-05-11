import 'package:flutter/material.dart';
import '../pagesAdmin/admin_project_page.dart';
import '../pagesAdmin/admin_message_page.dart';
import '../theme/colors.dart';

class AdminNavContainer extends StatefulWidget {
  const AdminNavContainer({super.key});

  @override
  State<AdminNavContainer> createState() => _AdminNavContainerState();
}

class _AdminNavContainerState extends State<AdminNavContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [AdminMessagePage(), AdminProjectPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.beige,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projets'),
        ],
      ),
    );
  }
}
