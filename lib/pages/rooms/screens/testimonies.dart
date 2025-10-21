import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/providers/testimonies_provider.dart';
import 'package:dailydevotion/pages/rooms/screens/add_testimonies.dart';
import 'package:dailydevotion/pages/rooms/widgets/testimonie_text_post_card.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TestimoniesScreen extends StatefulWidget {
  final AppLocalizations tr;
  final UserModel user;
  const TestimoniesScreen({super.key, required this.user, required this.tr});

  @override
  State<TestimoniesScreen> createState() => _TestimoniesScreenState();
}

class _TestimoniesScreenState extends State<TestimoniesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch testimonies only once when screen loads
    Future.microtask(
      () => context.read<TestimoniesProvider>().fetchTestimonies(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    return Scaffold(
      body: Consumer<TestimoniesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.testimonies.isEmpty) {
            return _buildShimmerLoading();
          }
          if (provider.testimonies.isEmpty) {
            return  Center(
              child: Text(widget.tr.nothingHereYet),
            );
          }
          return ListView.builder(
            itemCount: provider.testimonies.length,
            itemBuilder: (context, index) {
              final testimony = provider.testimonies[index];
              return TestimoniesTextPostCard(testimony: testimony, tr:  widget.tr,);
              // Make sure TextPostCard supports `testimony` param
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
      heroTag: "fab_testimonies", // unique tag
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTestimony(user: widget.user, tr: widget.tr,),
            ),
          );
        },
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
