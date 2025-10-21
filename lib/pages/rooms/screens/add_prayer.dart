import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/models/prayer_model.dart';
import 'package:dailydevotion/pages/rooms/providers/prayer_provider.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPrayer extends StatefulWidget {
  final AppLocalizations tr;
  final UserModel user;
  const AddPrayer({super.key, required this.user, required this.tr});

  @override
  State<AddPrayer> createState() => _AddPrayerState();
}

class _AddPrayerState extends State<AddPrayer> {
  final prayerController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: widget.tr.sharePrayers),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          (widget.user.profilePic != null &&
                              widget.user.profilePic!.isNotEmpty)
                          ? NetworkImage(widget.user.profilePic!)
                          : null,
                      child:
                          (widget.user.profilePic == null ||
                              widget.user.profilePic!.isEmpty)
                          ? Text(
                              widget.user.name.isNotEmpty
                                  ? widget.user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.user.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Post text field
                TextFormField(
                  controller: prayerController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: "${widget.tr.writePrayers}....",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return widget.tr.prayerEmptyError;
                    }
                  },
                  style: theme.textTheme.bodyLarge,
                ),

                const SizedBox(height: 12),

                // Post button
                CustomButton(
                  label: context.watch<PrayerProvider>().isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          // "Share",
                          widget.tr.share,
                          style: TextStyle(color: Colors.white),
                        ),
                  onTap: () async {
                    if (_formkey.currentState!.validate()) {
                      final provider = context.read<PrayerProvider>();

                      final prayer = PrayerModel(
                        id: FirebaseFirestore.instance
                            .collection('prayers')
                            .doc()
                            .id,
                        uid: widget.user.uid,
                        prayerText: prayerController.text.trim(),
                        createdAt: DateTime.now(),
                        likes: [],
                        likesCount: 0,
                        comments: [],
                        commentsCount: 0,
                      );

                      await provider.addPrayer(prayer);

                      if (!provider.isLoading) {
                        Navigator.pop(context); // go back to feed after posting
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
