import 'package:flutter/material.dart';

import 'create_request_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'my_requests_screen.dart';

class DashboardScreen extends StatefulWidget {

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  int currentIndex = 0;

  final List<Widget> pages = [

    const CreateRequestScreen(),

    MapScreen(),

    const MyRequestsScreen(),

    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF8FAFC),

      body: SafeArea(

        child: pages[currentIndex],
      ),

      bottomNavigationBar: Container(

        margin: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
          BorderRadius.circular(30),

          boxShadow: [

            BoxShadow(

              color: Colors.black
                  .withOpacity(0.08),

              blurRadius: 25,

              offset: const Offset(0, 10),
            ),
          ],
        ),

        child: ClipRRect(

          borderRadius:
          BorderRadius.circular(30),

          child: BottomNavigationBar(

            currentIndex:
            currentIndex,

            onTap: (index) {

              setState(() {

                currentIndex =
                    index;
              });
            },

            backgroundColor:
            Colors.white,

            selectedItemColor:
            const Color(0xFF2563EB),

            unselectedItemColor:
            Colors.grey,

            elevation: 0,

            type:
            BottomNavigationBarType.fixed,

            selectedLabelStyle:
            const TextStyle(

              fontWeight:
              FontWeight.w600,
            ),

   items: const [

  BottomNavigationBarItem(
    icon: Icon(Icons.home_rounded),
    label: "Home",
  ),

  BottomNavigationBarItem(
    icon: Icon(Icons.map_rounded),
    label: "Map",
  ),

  BottomNavigationBarItem(
    icon: Icon(Icons.receipt_long_rounded),
    label: "Requests",
  ),

  BottomNavigationBarItem(
    icon: Icon(Icons.person_rounded),
    label: "Profile",
  ),

],
          ),
        ),
      ),
    );
  }
}