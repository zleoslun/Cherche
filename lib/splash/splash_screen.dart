import 'package:dailydevotion/auth/auth_wrapper.dart';
import 'package:dailydevotion/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    var size = MediaQuery.of(context).size;
    final double width = size.width;
    final String srclight = 'assets/icons/for_light.png';
    final String srcdark = 'assets/icons/for_dark_logo.png';
    return Scaffold(
      body: Center(
        child: themeProvider.isDarkMode
            ? Image.asset(srcdark, width: width * 0.5)
            : Image.asset(srclight, width: width * 0.5),
      ),
    );
  }
}
