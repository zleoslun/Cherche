import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/providers/prayer_provider.dart';
import 'package:dailydevotion/pages/rooms/screens/add_prayer.dart';
import 'package:dailydevotion/pages/rooms/widgets/text_post_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PrayersScreen extends StatefulWidget {
  final AppLocalizations tr;
  final UserModel user;
  const PrayersScreen({super.key, required this.user, required this.tr});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen>
    with AutomaticKeepAliveClientMixin {
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true; // Keeps the state alive when switching tabs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePrayers();
    });
  }

  Future<void> _initializePrayers() async {
    if (!_hasInitialized) {
      await context.read<PrayerProvider>().fetchPrayers();
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      body: Consumer<PrayerProvider>(
        builder: (context, provider, _) {
          // Show shimmer while loading and no prayers exist
          if (provider.isLoading && provider.prayers.isEmpty) {
            return _buildShimmerLoading();
          }

          // Show empty state if no prayers
          if (provider.prayers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    // "Nothing here yet",
                    widget.tr.nothingHereYet,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    // "Be the first to share a prayer",
                    widget.tr.beFirstToSharePrayer,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchPrayers();
            },
            child: ListView.builder(
              itemCount: provider.prayers.length,
              itemBuilder: (context, index) {
                final prayer = provider.prayers[index];
                return TextPostCard(prayer: prayer, tr: widget.tr);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_prayer", // different tag
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPrayer(user: widget.user, tr: widget.tr),
            ),
          );
          // Optionally refresh prayers when returning from add prayer screen
          // if (result == true) {
          //   context.read<PrayerProvider>().fetchPrayers();
          // }
        },
        backgroundColor: const Color(0xFF130E6A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // Show 5 shimmer cards
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row shimmer
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 80,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Content shimmer
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action bar shimmer
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 20,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
