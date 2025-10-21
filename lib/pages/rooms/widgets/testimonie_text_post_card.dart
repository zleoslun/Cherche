import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/rooms/models/testimonies_model.dart';
import 'package:dailydevotion/pages/rooms/models/room_comment_model.dart';
import 'package:dailydevotion/pages/rooms/providers/testimonies_provider.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestimoniesTextPostCard extends StatelessWidget {
  final TestimoniesModel testimony;
  final AppLocalizations tr;
  const TestimoniesTextPostCard({
    super.key,
    required this.testimony,
    required this.tr,
  });

  // String _formatTimeAgo(DateTime date) {
  //   final diff = DateTime.now().difference(date);
  //   if (diff.inMinutes < 1) return "Just now";
  //   if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
  //   if (diff.inHours < 24) return "${diff.inHours}h ago";
  //   return "${diff.inDays}d ago";
  // }

  String _formatTimeAgo(DateTime date, AppLocalizations tr) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return tr.justNow;
    if (diff.inMinutes < 60) return tr.minuteAgo(diff.inMinutes);
    if (diff.inHours < 24) return tr.hourAgo(diff.inHours);
    return tr.dayAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final theme = Theme.of(context);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(testimony.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        final userData = snapshot.data!.data();
        final authorName = userData?['name'] ?? 'Unknown';
        final authorAvatarUrl = userData?['profilePic'] ?? '';
        final isLiked = testimony.likes.contains(currentUserId);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: authorAvatarUrl.isNotEmpty
                          ? NetworkImage(authorAvatarUrl)
                          : null,
                      child: authorAvatarUrl.isEmpty
                          ? Text(
                              authorName.isNotEmpty
                                  ? authorName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTimeAgo(testimony.createdAt, tr),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Post content
                Text(
                  testimony.testimonyText,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),

                const SizedBox(height: 12),

                // Action bar
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: () {
                        context.read<TestimoniesProvider>().toggleLike(
                          testimony.id,
                          currentUserId,
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    Text("${testimony.likesCount}"),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.mode_comment_outlined, size: 20),
                      onPressed: () {
                        _openCommentSheet(
                          context,
                          testimony,
                          authorName,
                          authorAvatarUrl,
                          themeProvider,
                          tr,
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    Text("${testimony.commentsCount}"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCommentSheet(
    BuildContext context,
    TestimoniesModel testimony,
    String authorName,
    String authorAvatarUrl,
    ThemeProvider themeProvider,
    AppLocalizations tr,
  ) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  // "Comments",
                  tr.comment,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                // Expanded(
                //   child: Consumer<TestimoniesProvider>(
                //     builder: (context, provider, _) {
                //       final currentTestimony = provider.testimonies.firstWhere(
                //         (t) => t.id == testimony.id,
                //         orElse: () => testimony,
                //       );

                //       if (currentTestimony.comments.isEmpty) {
                //         return  Center(child: Text(tr.noComments));
                //       }

                //       return ListView.builder(
                //         itemCount: currentTestimony.comments.length,
                //         itemBuilder: (context, index) {
                //           final comment = currentTestimony.comments[index];

                //           return StreamBuilder<
                //             DocumentSnapshot<Map<String, dynamic>>
                //           >(
                //             stream: FirebaseFirestore.instance
                //                 .collection('users')
                //                 .doc(comment.userId)
                //                 .snapshots(),
                //             builder: (context, snapshot) {
                //               String commenterName = "User";
                //               String commenterAvatar = "";

                //               if (snapshot.hasData &&
                //                   snapshot.data!.data() != null) {
                //                 final data = snapshot.data!.data()!;
                //                 commenterName = data['name'] ?? "User";
                //                 commenterAvatar = data['profilePic'] ?? "";
                //               }

                //               return ListTile(
                //                 leading: CircleAvatar(
                //                   radius: 16,
                //                   backgroundImage: commenterAvatar.isNotEmpty
                //                       ? NetworkImage(commenterAvatar)
                //                       : null,
                //                   child: commenterAvatar.isEmpty
                //                       ? Text(
                //                           commenterName.isNotEmpty
                //                               ? commenterName[0].toUpperCase()
                //                               : "?",
                //                           style: const TextStyle(
                //                             fontWeight: FontWeight.bold,
                //                             fontSize: 14,
                //                           ),
                //                         )
                //                       : null,
                //                 ),
                //                 title: Text(commenterName),
                //                 subtitle: Text(comment.text),
                //                 trailing: Text(
                //                   _formatTimeAgo(comment.createdAt.toDate()),
                //                   style: const TextStyle(fontSize: 10),
                //                 ),
                //               );
                //             },
                //           );
                //         },
                //       );
                //     },
                //   ),
                // ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('testimonies')
                        .doc(testimony.id)
                        .collection('comments')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: SizedBox());
                      }

                      final comments = snapshot.data!.docs.map((doc) {
                        final comment = RoomCommentModel.fromMap(doc.data());
                        return comment.copyWith(
                          id: doc.id,
                        ); // assign the doc ID here
                      }).toList();

                      if (comments.isEmpty) {
                        return Center(child: Text(tr.noComments));
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>
                          >(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(comment.userId)
                                .snapshots(),
                            builder: (context, userSnapshot) {
                              String commenterName = "User";
                              String commenterAvatar = "";

                              if (userSnapshot.hasData &&
                                  userSnapshot.data!.data() != null) {
                                final data = userSnapshot.data!.data()!;
                                commenterName = data['name'] ?? "User";
                                commenterAvatar = data['profilePic'] ?? "";
                              }

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: commenterAvatar.isNotEmpty
                                      ? NetworkImage(commenterAvatar)
                                      : null,
                                  child: commenterAvatar.isEmpty
                                      ? Text(
                                          commenterName.isNotEmpty
                                              ? commenterName[0].toUpperCase()
                                              : "?",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(commenterName),
                                subtitle: Text(comment.text),
                                trailing: Text(
                                  _formatTimeAgo(
                                    comment.createdAt.toDate(),
                                    tr,
                                  ),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.grey[800]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: "${tr.addComment}...",
                              hintStyle: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF130E6A),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () async {
                            final text = commentController.text.trim();
                            if (text.isEmpty) return;

                            final user = FirebaseAuth.instance.currentUser!;
                            final comment = RoomCommentModel(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              userId: user.uid,
                              text: text,
                              userName: authorName,
                              userImage: authorAvatarUrl,
                              createdAt: Timestamp.now(),
                            );

                            await context
                                .read<TestimoniesProvider>()
                                .addComment(
                                  testimonyId: testimony.id,
                                  comment: comment,
                                );

                            commentController.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
