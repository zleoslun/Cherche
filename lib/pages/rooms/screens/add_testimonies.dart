import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/models/testimonies_model.dart';
import 'package:dailydevotion/pages/rooms/providers/testimonies_provider.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddTestimony extends StatefulWidget {
  final UserModel user;
  final AppLocalizations tr;
  const AddTestimony({super.key, required this.user, required this.tr});

  @override
  State<AddTestimony> createState() => _AddTestimonyState();
}

class _AddTestimonyState extends State<AddTestimony> {
  final testimonyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar:  CustomAppBar(title: widget.tr.shareTestimonies),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                  controller: testimonyController,
                  maxLines: 8,
                  decoration:  InputDecoration(
                    hintText: widget.tr.writeTestimony,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return widget.tr.emptyTestimonyError;
                    }
                    return null;
                  },
                  style: theme.textTheme.bodyLarge,
                ),
            
                const SizedBox(height: 12),
            
                // Post button
                CustomButton(
                  label: context.watch<TestimoniesProvider>().isLoading
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
                      :  Text(
                          // "Share",
                          widget.tr.share,
                          style: TextStyle(color: Colors.white),
                        ),
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      final provider = context.read<TestimoniesProvider>();
            
                      final testimony = TestimoniesModel(
                        id: FirebaseFirestore.instance
                            .collection('testimonies')
                            .doc()
                            .id,
                        uid: widget.user.uid,
                        testimonyText: testimonyController.text.trim(),
                        createdAt: DateTime.now(),
                        likes: [],
                        likesCount: 0,
                        comments: [],
                        commentsCount: 0,
                      );
            
                      await provider.addTestimony(testimony);
            
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
