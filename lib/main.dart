import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_messenger/screens/chat/chatpage.dart';
import 'package:flutter_messenger/screens/landing.dart';
import 'package:flutter_messenger/screens/user/login.dart';
import 'package:flutter_messenger/screens/user/siqnup.dart';
import 'package:flutter_messenger/services/auth.dart';
import 'package:flutter_messenger/services/chat/notification_service.dart';
import 'package:flutter_messenger/themes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  

    if (message.notification != null) {
      _showFlutterNotification(message);
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessageOpenedApp.listen(_navigateToChat);

  await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  runApp(const MainApp());
}

void _showFlutterNotification(RemoteMessage message) {
  NotificationService.showNotification(
    message,
  );
}

void _navigateToChat(RemoteMessage message) {
  final senderId = message.data['senderId'];

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) => ChatPage(
        receiverUserId: senderId,
        receiverUserNickname: message.notification?.title ?? 'User',
      ),
    ),
  );
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
