import 'package:flutter/material.dart';
import '../pagesAdmin/admin_home_page.dart';
import '../pagesAdmin/admin_message_page.dart';
import '../pagesAdmin/admin_orders_page.dart';
import '../pagesAdmin/admin_inventory_page.dart';
import '../pagesAdmin/admin_stats_page.dart';
import '../theme/colors.dart';

class AdminNavContainer extends StatefulWidget {
  const AdminNavContainer({super.key});

  @override
  State<AdminNavContainer> createState() => _AdminNavContainerState();
}

class _AdminNavContainerState extends State<AdminNavContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AdminHomePage(),
    AdminMessagePage(),
    AdminOrdersPage(),
    AdminInventoryPage(),
    AdminStatsPage(),
  ];

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
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Messages'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
