import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
}
