import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:async/async.dart';
import '../pages/home_page.dart';
import '../pages/full_gallery_page.dart';
import '../pages/project_page.dart';
import '../pages/message_page.dart';
import '../pages/profile_page.dart';
import '../theme/colors.dart';
import 'package:another_flushbar/flushbar.dart';

class BottomNavContainer extends StatefulWidget {
  final int initialIndex;

  const BottomNavContainer({super.key, this.initialIndex = 0});

  @override
  State<BottomNavContainer> createState() => _BottomNavContainerState();
}

class _BottomNavContainerState extends State<BottomNavContainer> {
  late int _selectedIndex;
  int unreadMessages = 0;
  StreamSubscription? _subscription;

  final List<Widget> _pages = const [
    HomePage(),
    FullGalleryPage(),
    ProjectPage(),
    MessagePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _listenToUnreadMessages();
  }

  void _listenToUnreadMessages() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userId = currentUser.uid;

    final convs =
        await FirebaseFirestore.instance
            .collection('messages')
            .where('participants', arrayContains: userId)
            .get();

    _subscription?.cancel();

    final streams = convs.docs.map((conv) {
      final convId = conv.id;
      return FirebaseFirestore.instance
          .collection('messages')
          .doc(convId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .snapshots();
    });

    _subscription = StreamGroup.merge(streams).listen((event) {
      final count = event.docs.length;

      if (count > unreadMessages && _selectedIndex != 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Flushbar(
              message: "📩 Nouveau message de Chewlin !",
              duration: const Duration(seconds: 4),
              backgroundColor: AppColors.green,
              flushbarPosition: FlushbarPosition.TOP,
              borderRadius: BorderRadius.circular(12),
              margin: const EdgeInsets.all(12),
              animationDuration: const Duration(milliseconds: 500),
              forwardAnimationCurve: Curves.easeOut,
              icon: const Icon(Icons.markunread, color: Colors.white),
            ).show(context);
          });
        });
      }

      setState(() {
        unreadMessages = count;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 3) {
        unreadMessages = 0;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
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
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Galerie',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Project',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.send),
                if (unreadMessages > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadMessages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Message',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
