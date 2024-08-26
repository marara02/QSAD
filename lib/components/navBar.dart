import 'package:flutter/material.dart';
import 'package:safedriving/pages/homePage.dart';
import 'package:safedriving/pages/info_page.dart';
import 'package:safedriving/pages/mainPage.dart';
import 'package:safedriving/pages/profile.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({super.key});

  @override
  State<NavigationBarWidget> createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          ],
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFbcdeff), // A second color for the gradient
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          // Background is transparent to show the gradient
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          indicatorColor: Color(0xFF65BEFF),
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.analytics),
              icon: Icon(Icons.analytics_outlined),
              label: 'History',
            ),
            // NavigationDestination(
            //   selectedIcon: Icon(Icons.message),
            //   icon: Icon(Icons.message_outlined),
            //   label: 'Help',
            // ),
            NavigationDestination(
              icon: Badge(child: Icon(Icons.car_repair)),
              label: 'Drive',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person_2),
              icon: Icon(Icons.person_2_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: <Widget>[
        /// History page
        MainPage(),

        // /// Help page
        // InfoPage(),

        /// New Driving page
        const MyHomePage(),

        /// Profile page
        const Profile()
      ][currentPageIndex],
    );
  }
}
