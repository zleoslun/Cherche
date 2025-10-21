import 'package:dailydevotion/admin/settings/privacy/change_password.dart';
import 'package:dailydevotion/auth/login.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/stripe/make_payment.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySettingMain extends StatelessWidget {
  final AppLocalizations tr;
  const PrivacySettingMain({super.key, required this.tr});

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 🔥 Delete user from Firebase Authentication
      await user.delete();

      // 🔥 Force logout after deletion
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );

        // Navigate to login page and remove all routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                Login(), // replace with your login screen widget
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // If re-authentication required, Firebase will throw an error here
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error deleting account: $e")));
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteAccount),
        content: Text(
          // "This action cannot be undone.\n\nAre you sure you want to delete your account?",
          "${tr.actionCannotBeUndone}\n\n${tr.deleteAccountConfirmation}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop(); // close dialog
              await _deleteAccount(context);
            },
            child: Text(tr.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    return Scaffold(
      appBar: CustomAppBar(title: tr.privacySettings),
      body: Padding(
        padding: EdgeInsets.only(
          left: width * 0.05,
          right: width * 0.05,
          top: height * 0.01,
        ),
        child: Column(
          children: [
            // Change password card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(tr: tr),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.lock_outline),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            tr.changePassword,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Delete account card
            GestureDetector(
              onTap: () => _showDeleteDialog(context),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_forever),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            // "Delete Account",
                            tr.deleteAccount,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}
