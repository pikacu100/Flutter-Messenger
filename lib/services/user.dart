import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_messenger/services/chat/notification_service.dart';

class UserData {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> createUserDoc() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'email': user?.email,
        'uid': user?.uid,
      });
    } catch (e) {
      print("Error creating user document: $e");
    }
  }

  Future<void> updateUserNickname(String name) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'nickname': name,
      });
    } catch (e) {
      print("Error updating user nickname: $e");
    }
  }

  Future<void> removeFriend(String snapshotId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('friends')
          .doc(snapshotId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error removing friend: $e");
      }
    }
  }

  Future<void> storeFCMToken(String userId) async {
    final token = await NotificationService.getDeviceToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }
    
  }

  void updateUserActivity(String userId) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'lastActive': FieldValue.serverTimestamp()});
    }
}
