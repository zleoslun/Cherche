// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dailydevotion/admin/providers/video_provider1.dart';
// import 'package:dailydevotion/firebase_options.dart';
// import 'package:dailydevotion/l10n/app_localizations.dart';
// import 'package:dailydevotion/pages/rooms/providers/prayer_provider.dart';
// import 'package:dailydevotion/pages/rooms/providers/testimonies_provider.dart';
// import 'package:dailydevotion/providers/locale_provider.dart';

// import 'package:dailydevotion/splash/splash_screen.dart';
// import 'package:dailydevotion/auth/auth_services_provider.dart';
// import 'package:dailydevotion/utils/theme/theme_provider.dart';
// import 'package:dailydevotion/providers/user_provider.dart';
// import 'package:dailydevotion/utils/theme/theme.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:provider/provider.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   //
//   // Fetch Stripe config from Firestore
//   final doc = await FirebaseFirestore.instance
//       .collection('config')
//       .doc('stripe')
//       .get();

//   final publishableKey = doc['publishableKey'];
//   print(
//     "Here is the \n Pubnlishable \n key that \n you want \n $publishableKey",
//   );

//   Stripe.publishableKey = publishableKey;
//   await Stripe.instance.applySettings();
//   final themeProvider = ThemeProvider();
//   await themeProvider.loadPreferences();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => themeProvider),
//         ChangeNotifierProvider(create: (context) => AuthServiceProvider()),
//         ChangeNotifierProvider(create: (context) => UserProvider()),
//         ChangeNotifierProvider(create: (context) => VideoProvider1()),
//         ChangeNotifierProvider(create: (context) => PrayerProvider()),
//         ChangeNotifierProvider(create: (context) => TestimoniesProvider()),
//         ChangeNotifierProvider(create: (context) => LocaleProvider()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// //
// Future<void> initializeStripeIfEnabled() async {
//   try {
//     final doc = await FirebaseFirestore.instance
//         .collection('config')
//         .doc('stripe')
//         .get();

//     final isEnabled = doc['enabled'] ?? false;

//     if (isEnabled) {
//       final publishableKey = doc['publishableKey'];
//       print("Stripe is enabled. Publishable Key: $publishableKey");

//       Stripe.publishableKey = publishableKey;
//       await Stripe.instance.applySettings();
//     } else {
//       print("Stripe is disabled in Firestore. Skipping initialization.");
//     }
//   } catch (e) {
//     print("Error initializing Stripe: $e");
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final localeProvider = Provider.of<LocaleProvider>(context);
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       supportedLocales: const [
//         Locale('en'), // English
//         Locale('fr'), // French
//       ],
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       locale: localeProvider.locale, // 👈 dynamic locale
//       // for 1x Text size
//       builder: (context, child) {
//         final mediaQuery = MediaQuery.of(context);
//         return MediaQuery(
//           data: mediaQuery.copyWith(textScaler: TextScaler.linear(1.0)),
//           child: child!,
//         );
//       },
//       title: 'Cherche',
//       // theme: AppTheme.lightTheme,
//       theme: AppTheme.lightTheme, // 🌞 Light
//       darkTheme: AppTheme.darkTheme, // 🌙 Dark
//       themeMode: themeProvider.themeMode, // controlled by provider
//       home: SplashScreen(),
//     );
//   }
// }
