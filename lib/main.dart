import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/firebase_options.dart';
import 'package:flutter_messenger/screens/landing.dart';
import 'package:flutter_messenger/screens/user/login.dart';
import 'package:flutter_messenger/screens/user/siqnup.dart';
import 'package:flutter_messenger/services/auth.dart';
import 'package:flutter_messenger/themes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  void handleThemeChange(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginService(onThemeChanged: handleThemeChange),
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      navigatorObservers: <NavigatorObserver>[observer],
      navigatorKey: navigatorKey,
      routes: {
        '/landing': (context) => LandingPage(onThemeChanged: handleThemeChange),
        '/authLog': (context) => LoginService(
              onThemeChanged: handleThemeChange,
            ),
        '/authSig': (context) => SignUpService(
              onThemeChanged: handleThemeChange,
            ),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const Loginpage(),
      },
    );
  }
}
