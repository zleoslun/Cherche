import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dailydevotion/auth/auth_services_provider.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:dailydevotion/widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgetPassword extends StatefulWidget {
  final AppLocalizations tr;
  const ForgetPassword({super.key, required this.tr});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthServiceProvider>(
        context,
        listen: false,
      );

      try {
        await authProvider.resetPassword(email: _emailController.text.trim());

        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: widget.tr.success,
                  message: widget.tr.resetLinkSent,
                  contentType: ContentType.success,
                ),
              ),
            );

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } catch (e) {
        // Show an error message
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Oh Snap!',
                  message: '${widget.tr.resetLinkFailed}: ${e.toString()}',
                  contentType: ContentType.failure,
                ),
              ),
            );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

  
    return Scaffold(
      appBar: CustomAppBar(
        // title: "Forget Password"
        title: widget.tr.forgotPassword,
      ),
      body: Consumer<AuthServiceProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.05,
              vertical: height * 0.02,
            ),

            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextformfield(
                    // hint: "Enter Email to send Reset Link",
                    // labelText: "Email",
                    hint: widget.tr.resetPasswordTitle,
                    labelText: widget.tr.emailLabel,
                    controller: _emailController,
                    textInputType: TextInputType.emailAddress,
                    prefix: const Icon(Icons.mail),

                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: height * 0.01),

                  // Button

                  //
                  // CustomButton(

                  //   label: "send Reset Link",
                  //   isLoading: authProvider.isLoading,
                  //   onTap: authProvider.isLoading ? null : _sendResetLink,
                  // ),
                  CustomButton(
                    isLoading: authProvider.isLoading,
                    label: Text(
                      // "send Reset Link",
                      widget.tr.sendResetLink,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: authProvider.isLoading ? null : _sendResetLink,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
