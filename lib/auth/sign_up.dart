import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dailydevotion/auth/login.dart';
import 'package:dailydevotion/auth/auth_services_provider.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:dailydevotion/widgets/custom_textformfield.dart'
    show CustomTextformfield;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' show Provider;

class SignUp extends StatefulWidget {
  final AppLocalizations tr;
  const SignUp({super.key, required this.tr});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Controllers
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final profStatusController = TextEditingController();
  final bioController = TextEditingController();
  final bool obscureText = false;
  final _formkey = GlobalKey<FormState>();

  //
  Future<void> _doSignUp(AuthServiceProvider authService) async {
    if (!_formkey.currentState!.validate()) return;
    if (passController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: widget.tr.passwordsDoNotMatch,
              contentType: ContentType.failure,
            ),
          ),
        );
      return;
    }

    try {
      await authService.signUp(
        email: emailController.text,
        password: passController.text,
        name: nameController.text,
        // professionalstatus: profStatusController.text,
        // bio: bioController.text
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: widget.tr.success,
              message: widget.tr.signUpSuccess,
              contentType: ContentType.success,
            ),
          ),
        );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Oh Snap!',
              message: error.toString(),
              contentType: ContentType.failure,
            ),
          ),
        );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServiceProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    //
    // final tr = AppLocalizations.of(context)!;
    // final provider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //

                  //
                  
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: height * 0.07),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          themeProvider.isDarkMode
                              ? Image.asset(
                                  'assets/icons/for_dark_logo.png',
                                  width: width * 0.4,
                                )
                              : Image.asset(
                                  'assets/icons/for_light.png',
                                  width: width * 0.4,
                                ),
                     
                        ],
                      ),
                    ),
                  ),

                  //
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.05),
                    child: Row(
                      children: [
                        Text(
                          // "Sign up to create account",
                          widget.tr.signUpTitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // color: themeProvider.isDarkMode
                            //     ? Colors.white
                            //     : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //

                  //
                  // Name
                  CustomTextformfield(
                    // hint: "Enter Full Name",
                    // labelText: "Name",
                    hint: widget.tr.enterFullName,
                    labelText: widget.tr.nameLabel,
                    controller: nameController,
                    textInputType: TextInputType.text,
                    prefix: Icon(Icons.person, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return widget.tr.nameRequired;
                      } else if (value.length < 2) {
                        return widget.tr.nameTooShort;
                      } else if (value.length > 20) {
                        return widget.tr.nameTooLong;
                      }
                      return null;
                    },
                  ),

               

                  // Email address
                  CustomTextformfield(
                    // hint: "Enter Email address",
                    // labelText: "Email Address",
                    hint: widget.tr.enterEmail,
                    labelText: widget.tr.emailLabel,
                    controller: emailController,
                    textInputType: TextInputType.emailAddress,
                    prefix: Icon(Icons.mail_outline, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return widget.tr.emailRequired;
                      } else if (!RegExp(
                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                      ).hasMatch(value)) {
                        return widget.tr.emailInvalid;
                      }
                      return null;
                    },
                  ),

                  // Password
                  CustomTextformfield(
                    // hint: "Must be 8 characters",
                    // labelText: "Create a Password",
                    hint: widget.tr.passwordRule,
                    labelText: widget.tr.createPassword,
                    controller: passController,
                    textInputType: TextInputType.visiblePassword,
                    prefix: Icon(Icons.lock_open, color: Colors.grey),
                    obscureText: true,
                    enableToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.tr.passwordRequired;
                      } else if (value.length < 8) {
                        return widget.tr.passwordTooShort;
                      } else if (value.length > 25) {
                        return widget.tr.passwordTooLong;
                      }
                      return null;
                    },
                  ),

                  //Confirm Password
                  CustomTextformfield(
                    // hint: "Confirm Password",
                    // labelText: "Confirm Password",
                    hint: widget.tr.confirmPassword,
                    labelText: widget.tr.confirmPassword,
                    controller: confirmPassController,
                    textInputType: TextInputType.visiblePassword,
                    prefix: Icon(Icons.lock_open, color: Colors.grey),
                    obscureText: true,
                    enableToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.tr.confirmPassword;
                      } else if (value != passController.text) {
                        return widget.tr.confirmPasswordsDoNotMatch;
                      }
                      return null;
                    },
                  ),

                  // Sign Up Button
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.03),
                    child: CustomButton(
                      isLoading: authService.isLoading,
                      label: Text(
                        // "Sign Up",
                        widget.tr.signUp,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => _doSignUp(authService),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // 'Already have an Account?',
                        widget.tr.alreadyHaveAccount,
                        style: TextStyle(
                          // fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Text(
                          // "Sign In",
                          widget.tr.signInButton,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? Colors.white54
                                : Color(0xFF130E6A),
                            // color: Colors.deepPurple,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            // fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
