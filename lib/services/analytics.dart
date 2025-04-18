import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Analytics {
 

  void logUserActive() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown user';
    FirebaseAnalytics.instance.logEvent(name: 'user_active', parameters: {
      'user_id': userId,
      'time': DateTime.now().toIso8601String()
    });
    print("User active: $userId");
  }

  void logUserInactive() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown user';
    FirebaseAnalytics.instance.logEvent(name: 'user_inactive', parameters: {
      'user_id': userId,
      'time': DateTime.now().toIso8601String()
    });
    print("User inactive: $userId");
  }

  void newAccountSignedUp() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown user';
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown user';
    FirebaseAnalytics.instance.logEvent(name: 'new_user', parameters: {
      'user_id': userId,
      'name': name,
      'time': DateTime.now().toIso8601String()
    });
    print("User inactive: $userId");
  }

  void accountDeleted() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown user';
    FirebaseAnalytics.instance.logEvent(name: 'account_delete', parameters: {
      'user_id': userId,
      'time': DateTime.now().toIso8601String()
    });
    print("User inactive: $userId");
  }
}
