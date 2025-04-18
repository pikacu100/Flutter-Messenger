import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/landing.dart';
import 'package:flutter_messenger/screens/user/login.dart';
import 'package:flutter_messenger/screens/user/newuser.dart';
import 'package:flutter_messenger/services/analytics.dart';

class LoginService extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;
  const LoginService({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Analytics().logUserActive();
            return  LandingPage(onThemeChanged: onThemeChanged,);
          } else {
            return const Loginpage();
          }
        },
      ),
    );
  }
}

class SignUpService extends StatelessWidget {
   final Function(ThemeMode) onThemeChanged;
  const SignUpService({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Loginpage();
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              }

              if (userSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${userSnapshot.error}'),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                Analytics().newAccountSignedUp();
                return NewUserPage(onThemeChanged: onThemeChanged,);
              }
              Analytics().logUserActive();
              return LandingPage(onThemeChanged: onThemeChanged,);
            },
          );
        },
      ),
    );
  }
}
