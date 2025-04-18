import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TypingIndicator {
  final String chatRoomId;
  final String currentUserId;
  final String receiverUserId;

  TypingIndicator(this.chatRoomId, this.currentUserId, this.receiverUserId);

  void updateTypingStatus(bool isTyping) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('chatrooms') 
          .doc(chatRoomId);
          
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        if (isTyping) {
          await docRef.update({'typingUsers.$currentUserId': true});
        } else {
          await docRef.update({'typingUsers.$currentUserId': FieldValue.delete()});
        }
      } else {
        await docRef.set({
          'typingUsers': isTyping ? {currentUserId: true} : {}
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating typing status: $e");
      }
    }
  }

  Stream<bool> isReceiverTyping() {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            final typingUsers = data['typingUsers'] as Map<String, dynamic>?;
            
            return typingUsers != null && typingUsers.containsKey(receiverUserId);
          }
          return false;
        });
  }
}