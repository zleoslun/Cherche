import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dailydevotion/auth/auth_wrapper.dart';
import 'package:dailydevotion/auth/forget_password.dart';
import 'package:dailydevotion/auth/sign_up.dart';
import 'package:dailydevotion/auth/auth_services_provider.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/providers/locale_provider.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/custom_button.dart';
import 'package:dailydevotion/widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controllers
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final bool obscureText = false;
  final _formkey = GlobalKey<FormState>();

  Future<void> _doLogin(
    AuthServiceProvider authService,
    AppLocalizations tr,
  ) async {
    if (!_formkey.currentState!.validate()) return;

    try {
      await authService.login(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      // Ensure the widget is still in the tree before showing a SnackBar or navigating.
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: tr.success,
              message: tr.loginSuccess,
              contentType: ContentType.success,
            ),
          ),
        );

      // Navigate directly to main screen after successful login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
        (Route<dynamic> route) => false, // removes all previous routes
      );
    } catch (error) {
      if (!mounted) return;
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
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServiceProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    //
    final tr = AppLocalizations.of(context)!;
    final provider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      // appBar: CustomAppBar(
      //   title: "",
      //   actions: [

      //   ],
      // ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DropdownButton<Locale>(
                        underline: const SizedBox(), // remove default underline
                        icon: Icon(
                          Icons.language,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                        value: provider.locale,
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            provider.setLocale(newLocale);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: Locale('en'),
                            child: Text("English"),
                          ),
                          DropdownMenuItem(
                            value: Locale('fr'),
                            child: Text("Français"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: height * 0.1),
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
                         
                          // ),
                        ],
                      ),
                    ),
                  ),

                 

                 
                  //
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.05),
                    child: Text(
                      // "Sign in to your account",
                      tr.signInTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // color: themeProvider.isDarkMode
                        //     ? Colors.white
                        //     : Colors.black,
                      ),
                    ),
                  ),
                  // Email address
                  CustomTextformfield(
                    // hint: "Email address",
                    hint: tr.emailLabel,
                    // labelText: "Email Address",
                    labelText: tr.emailLabel,

                    controller: emailController,
                    textInputType: TextInputType.emailAddress,
                    prefix: Icon(Icons.mail_outline, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return tr.emailRequired;
                      } else if (!RegExp(
                        r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                      ).hasMatch(value)) {
                        return tr.emailInvalid;
                      }
                      return null;
                    },
                  ),

                  // Password
                  CustomTextformfield(
                    // hint: "Password",
                    // labelText: "Password",
                    hint: tr.passwordLabel,
                    labelText: tr.passwordLabel,
                    controller: passController,
                    textInputType: TextInputType.visiblePassword,
                    prefix: Icon(Icons.lock_open, color: Colors.grey),
                    obscureText: true,
                    enableToggle: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr.passwordRequired;
                      } else if (value.length < 8) {
                        return tr.passwordTooShort;
                      } else if (value.length > 25) {
                        return tr.passwordTooLong;
                      }
                      return null;
                    },
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: height * 0.01),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgetPassword(tr: tr),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          // "Forget Password?",
                          tr.forgotPassword,
                          style: TextStyle(
                            color: themeProvider.isDarkMode
                                ? Colors.white54
                                : Color(0xFF130E6A),
                            // fontSize: 16,
                            fontFamily: GoogleFonts.inter().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Login Up Button
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: CustomButton(
                        isLoading: authService.isLoading,
                        label: Text(
                          // "Sign in ",
                          tr.signInButton,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () => _doLogin(authService, tr),
                      ),
                    ),
                  ),

                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // "Don't have an Account?",
                        tr.noAccount,
                        style: TextStyle(
                          // fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUp(tr: tr),
                            ),
                          );
                        },
                        child: Text(
                          // "Sign up",
                          tr.signUp,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            // color: Colors.deepPurple,
                            // fontSize: 16,
                            color: themeProvider.isDarkMode
                                ? Colors.white54
                                : Color(0xFF130E6A),
                            fontFamily: GoogleFonts.inter().fontFamily,
                            fontWeight: FontWeight.bold,
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
