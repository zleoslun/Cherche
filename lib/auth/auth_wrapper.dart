import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/admin/navbar/admin_navbar.dart';
import 'package:dailydevotion/auth/login.dart';

import 'package:dailydevotion/pages/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: SizedBox()));
        }

        if (snapshot.hasData) {
          // User is logged in → now check Firestore role
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: SizedBox()));
              }

              if (userSnapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Error loading user data')),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // ⚡ FIX: don’t fall back to NavBar too early
                return const Scaffold(body: Center(child: SizedBox()));
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final String role = userData['role'] ?? 'user';

              // Debug print to verify role
              debugPrint("🔥 User role from Firestore: $role");

              // Navigate based on role
              if (role == 'admin') {
                return const AdminNavBar();
              } else {
                return const NavBar();
              }
            },
          );
        } else {
          // User not logged in → go to login screen
          return const Login();
        }
      },
    );
  }
}
