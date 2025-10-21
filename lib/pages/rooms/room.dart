import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/screens/prayers.dart';
import 'package:dailydevotion/pages/rooms/screens/testimonies.dart';
import 'package:dailydevotion/providers/premium_provider.dart';
import 'package:dailydevotion/stripe/make_payment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Rooms extends StatefulWidget {
  final UserModel user;
  final AppLocalizations tr;
  const Rooms({super.key, required this.user, required this.tr});

  @override
  State<Rooms> createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  //

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final provider = Provider.of<PremiumProvider>(context);

    //
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 🔒 Not premium
    if (!provider.hasValidSubscription!) {
      return _buildPremiumLockedState(width, widget.tr, provider);
    }

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
  Widget _buildPremiumLockedState(
    double width,
    AppLocalizations tr,
    PremiumProvider provider,
  ) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(Icons.lock, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              // "Premium Content Only",
              tr.premiumContentOnly,
              style: TextStyle(
                fontSize: width * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              // "Subscribe to unlock all videos and get exclusive content!",
              tr.subscribeToUnlock1,
              style: TextStyle(
                fontSize: width * 0.035,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: width * 0.5,
              // height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF130E6A),
                  foregroundColor: Colors.white,
                ),
                // onPressed: () async{
                //   // Navigate to subscription page
                //   await makePayment()
                // },
                onPressed: () async {
                  await makePayment(3100, context);
                  await provider.refreshSubscription();
                  // await makePayment(55, context); // = CHF 0.01
                },

                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    textAlign: TextAlign.center,
                    // "Subscribe Now",
                    tr.subscribeNow,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
