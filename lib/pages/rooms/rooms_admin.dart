import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/screens/prayers.dart';
import 'package:dailydevotion/pages/rooms/screens/testimonies.dart';
import 'package:flutter/material.dart';

class RoomsForAdmin extends StatefulWidget {
  final UserModel user;
  final AppLocalizations tr;
  const RoomsForAdmin({super.key, required this.user, required this.tr});

  @override
  State<RoomsForAdmin> createState() => _RoomsForAdminState();
}

class _RoomsForAdminState extends State<RoomsForAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
 
  }

  //
  

  //
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   

   
    return SafeArea(
      child: Column(
        children: [
          // TabBar without underline or icons
          Material(
            color: const Color(0xFF130E6A),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicator: const BoxDecoration(), // removes underline
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
              tabs: [
                Tab(text: widget.tr.prayers),
                Tab(text: widget.tr.testimonies),
              ],
            ),
          ),

          // TabBarView for content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PrayersScreen(user: widget.user, tr: widget.tr),
                TestimoniesScreen(user: widget.user, tr: widget.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //
 
}

//
