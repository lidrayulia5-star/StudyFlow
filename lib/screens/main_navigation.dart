import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'add_activity_screen.dart';
import 'dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {

  late int currentIndex;

  final pages = [
    const DashboardScreen(),
    const ActivityScreen(),
    const AddActivityScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar:
          BottomNavigationBar(
        type:
            BottomNavigationBarType.fixed,

        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "Aktivitas",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: "Tambah",
          ),
        ],
      ),
    );
  }
}