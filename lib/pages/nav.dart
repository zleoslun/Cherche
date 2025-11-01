import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/home/home.dart';
import 'package:dailydevotion/pages/rooms/room.dart';
import 'package:dailydevotion/pages/user%20settings/user_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// LEOS -- Importing common page
import 'package:dailydevotion/admin/navbar/resources.dart';

import '../../providers/user_provider.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await Provider.of<UserProvider>(context, listen: false).fetchUser(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final tr = AppLocalizations.of(context)!;

    if (user == null) {
      return const Scaffold(body: Center(child: SizedBox()));
    }

    // LEOS -- ADDING Resources Page
    final List<Widget> pages = [
      Home(user: user, tr: tr),
      Rooms(user: user, tr: tr),
      ResourcesScreen(),            // LEOS -- used both for users and admin
      UserSettingsPage(user: user, tr: tr),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF130E6A),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
            ],
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GNav(
                    rippleColor: Colors.white,
                    hoverColor: Colors.white,
                    gap: 6,
                    activeColor: Colors.white,
                    iconSize: 22,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.white.withOpacity(0.1),
                    color: Colors.grey[400],
                    tabs: [
                      GButton(icon: Icons.home,  text: tr.home),
                      GButton(icon: Icons.group, text: tr.rooms),
                      GButton(icon: Icons.menu_book, text: 'Resources'), // ⬅️ NUEVO
                      GButton(icon: Icons.settings, text: tr.settings),
                    ],
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() => _selectedIndex = index);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}