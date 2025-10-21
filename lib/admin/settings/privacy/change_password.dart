import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:dailydevotion/widgets/custom_textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  final AppLocalizations tr;
  const ChangePasswordScreen({super.key, required this.tr});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_newPasswordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.tr.passwordsDoNotMatch)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Re-authenticate user with current password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.tr.passwordChanged)));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == "wrong-password") {
        message = widget.tr.incorrectCurrentPassword;
      } else if (e.code == "weak-password") {
        message = "New password is too weak";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: tr.changePassword),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextformfield(
                  hint: tr.enterCurrentPassword,
                  labelText: tr.currentPassword,
                  controller: _currentPasswordController,
                  textInputType: TextInputType.visiblePassword,
                  prefix: Icon(Icons.lock_open),
                  obscureText: true,
                  enableToggle: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.enterCurrentPassword;
                    }
                    return null;
                  },
                ),
                CustomTextformfield(
                  hint: tr.enterNewPassword,
                  labelText: tr.newPassword,
                  controller: _newPasswordController,
                  textInputType: TextInputType.visiblePassword,
                  prefix: Icon(Icons.lock_open),
                  obscureText: true,
                  enableToggle: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.enterNewPassword;
                    } else if (value.length < 6) {
                      return tr.passwordTooShort;
                    }
                    return null;
                  },
                ),
                CustomTextformfield(
                  hint: tr.confirmNewPassword,
                  labelText: tr.confirmPassword,
                  controller: _confirmPasswordController,
                  textInputType: TextInputType.visiblePassword,
                  prefix: Icon(Icons.lock_open),
                  obscureText: true,
                  enableToggle: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr.confirmNewPassword;
                    } else if (value != _newPasswordController.text) {
                      return tr.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
          
                CustomButton(
                  label: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          tr.changePassword,
                          style: TextStyle(color: Colors.white),
                        ),
                  onTap: () => _changePassword(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
