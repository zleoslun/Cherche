import 'package:dailydevotion/Models/user.dart';
import 'package:dailydevotion/auth/login.dart';
import 'package:dailydevotion/admin/profile/edit_profile.dart';
import 'package:dailydevotion/admin/settings/privacy/privacy_setting_main.dart';
import 'package:dailydevotion/auth/auth_services_provider.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/pages/user%20settings/pages/contact_support.dart';
import 'package:dailydevotion/pages/user%20settings/pages/help_center.dart';
import 'package:dailydevotion/pages/user%20settings/pages/privacy_policy.dart';
import 'package:dailydevotion/pages/user%20settings/pages/terms_of_service.dart';
import 'package:dailydevotion/providers/locale_provider.dart';
import 'package:dailydevotion/stripe/make_payment.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:dailydevotion/widgets/custom_switch_tile.dart';
import 'package:dailydevotion/widgets/custom_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSettingsPage extends StatefulWidget {
  final UserModel user;
  final AppLocalizations tr;
  const UserSettingsPage({super.key, required this.user, required this.tr});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  bool autoUploadReminders = false;
  bool soundEffects = false;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: width * 0.05,
              right: width * 0.05,
              top: height * 0.02,
              bottom: height * 0.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  // "Settings",
                  widget.tr.settings,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (width < 550) ? 26 : 32,
                    // color: themeProvider.isDarkMode
                    //     ? Colors.white
                    //     : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Account Section
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[900]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      top: height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // "Account",
                          widget.tr.account,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (width < 550) ? 18 : 22,
                            // color: themeProvider.isDarkMode
                            //     ? Colors.white
                            //     : Colors.black87,
                          ),
                        ),

                        // const Divider(thickness: 0.5),
                        CustomTile(
                          // leading: const Icon(Icons.person, color: Colors.grey),
                          leadingText: "👤 ${widget.tr.editProfile}",
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(
                                  user: widget.user,
                                  tr: widget.tr,
                                ),
                              ),
                            );
                          },
                        ),
                        CustomTile(
                          // leading: const Icon(Icons.lock, color: Colors.yellow),
                          leadingText: "🔒 ${widget.tr.privacySettings}",
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PrivacySettingMain(tr: widget.tr),
                              ),
                            );
                          },
                        ),


                        //
                       
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // App prefrences
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[900]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      top: height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: height * 0.01),
                          child: Text(
                            // "App Prefrences",
                            widget.tr.appPreferences,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: (width < 550) ? 18 : 22,
                              // color: themeProvider.isDarkMode
                              //     ? Colors.white
                              //     : Colors.black87,
                            ),
                          ),
                        ),

                        //
                        CustomSwitchTile(
                          // leading: const Icon(
                          //   Icons.dark_mode,
                          //   color: Colors.yellow,
                          // ),
                          leadingText: "🌙 ${widget.tr.darkMode}",
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                        ),

                        // Language
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          leading: Icon(
                            Icons.language,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.blueAccent,
                          ),
                          title: const Text(
                            'Language',
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                          trailing: DropdownButtonHideUnderline(
                            child: DropdownButton<Locale>(
                              value: provider.locale,
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (Locale? newLocale) {
                                if (newLocale != null) {
                                  provider.setLocale(newLocale);
                                }
                              },
                              items: const [
                                DropdownMenuItem(
                                  value: Locale('en'),
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: Locale('fr'),
                                  child: Text('Français'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),
                // Support and info
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[900]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      top: height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // "Support and Info",
                          widget.tr.supportAndInfo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: (width < 550) ? 18 : 22,
                            // color: themeProvider.isDarkMode
                            //     ? Colors.white
                            //     : Colors.black87,
                          ),
                        ),

                        // const Divider(thickness: 0.5),
                        CustomTile(
                          // leading: const Icon(
                          //   Icons.question_mark,
                          //   color: Colors.red,
                          // ),
                          leadingText: "❓ ${widget.tr.helpCenter}",
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HelpCenter(tr: widget.tr),
                              ),
                            );
                          },
                        ),
                        CustomTile(
                          // leading: const Icon(Icons.email),
                          leadingText: "📧 ${widget.tr.contactSupport}",
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ContactSupport(tr: widget.tr),
                              ),
                            );
                          },
                        ),
                        CustomTile(
                          // leading: const Icon(Icons.file_copy),
                          leadingText: "📋 ${widget.tr.termsOfService}",
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TermsOfService(tr: widget.tr),
                              ),
                            );
                          },
                        ),
                        CustomTile(
                          // leading: const Icon(Icons.lock_clock),
                          leadingText: "🔐 ${widget.tr.privacyPolicy}",
                          ontap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PrivacyPolicy(tr: widget.tr),
                              ),
                            );
                          },
                        ),

                        //
                        // CustomTile(
                        //   // leading: const Icon(Icons.lock_clock),
                        //   leadingText: "🔐 Make Payment}",
                        //   ontap: () async {
                        //     await makePayment(1000); // $5.00
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(widget.tr.signOut),
                          content: Text(
                            // "Are you sure you want to sign out?"
                            widget.tr.signOutConfirm,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                // "Cancel",
                                widget.tr.cancel,
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final authprovider = AuthServiceProvider();
                                authprovider.signOut();
                                Navigator.of(context).pop();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: Text(
                                // "Yes",
                                widget.tr.yes,
                                style: TextStyle(
                                  // color: Colors.red,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      // color: themeProvider.isDarkMode
                      //     ? const Color.fromARGB(255, 255, 232, 235)
                      //     : Colors.red.shade50,
                      color: Color(0xFF130E6A),
                    ),
                    width: width,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          // "Sign Out",
                          widget.tr.signOut,
                          style: TextStyle(
                            // color: Colors.red,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
