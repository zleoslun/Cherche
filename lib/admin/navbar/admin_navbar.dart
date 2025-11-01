import 'package:dailydevotion/admin/home/admin_home.dart';
import 'package:dailydevotion/admin/mails/mails.dart';
import 'package:dailydevotion/admin/upload/admin_upload.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/room.dart';
import 'package:dailydevotion/pages/rooms/rooms_admin.dart';
import 'package:dailydevotion/pages/user%20settings/user_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dailydevotion/admin/navbar/resources.dart';

import '../../providers/user_provider.dart';

class AdminNavBar extends StatefulWidget {
  const AdminNavBar({super.key});

  @override
  State<AdminNavBar> createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBar> {
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

    // If user is not yet loaded, show a loader
    if (user == null) {
      return const Scaffold(body: Center(child: SizedBox()));
    }

    final List<Widget> pages = [
      AdminHome(user: user, tr: tr),
      AdminUpload(user: user, tr: tr),
      Mails(tr: tr),
      RoomsForAdmin(user: user, tr: tr),
      UserSettingsPage(user: user, tr: tr),
      const ResourcesScreen(),
    ];

    return Scaffold(
      // backgroundColor: Colors.white,
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
            top: false, // don’t push down
            bottom: false, // remove iOS home indicator padding
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GNav(
                    rippleColor: Colors.white,
                    hoverColor: Colors.white,
                    gap: 4,
                    activeColor: Colors.white,
                    iconSize: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    duration: const Duration(milliseconds: 400),
                    tabBackgroundColor: Colors.white.withOpacity(0.1),
                    color: Colors.grey[400],
                    tabs: [
                      GButton(icon: Icons.home, text: tr.home),
                      GButton(icon: Icons.movie, text: tr.upload),
                      GButton(icon: Icons.mail, text: tr.mails),
                      GButton(icon: Icons.group, text: tr.rooms),
                      GButton(icon: Icons.settings, text: tr.settings),
                      GButton(icon: Icons.menu_book, text: 'Resources'),
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
