import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_messenger/model/message.dart';
import 'package:flutter_messenger/services/encryption.dart';

class ChatService {
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final String senderId = currentUserId;
    final Timestamp timestamp = Timestamp.now();
    final String chatRoomId = getChatRoomId(senderId, receiverId);

    final String encryptedMessage =
        EncryptionService.encrypt(message, chatRoomId);

    Map<String, bool> seen = {
      senderId: true,
      receiverId: false,
    };

    Message newMessage = Message(
      message: encryptedMessage,
      senderId: senderId,
      receiverId: receiverId,
      timestamp: timestamp,
      seen: seen,
    );

    try {
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .set({
        'lastMessageTime': timestamp,
        'participants': [senderId, receiverId],
        'lastMessage': encryptedMessage,
        'hasUnseenMessages': {
          senderId: false,
          receiverId: true,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
    }
  }

  Future<void> markMessagesAsSeen({required String otherUserId}) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final String chatRoomId = getChatRoomId(currentUserId, otherUserId);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: otherUserId)
          .where('seen.$currentUserId', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({
          'seen.$currentUserId': true,
        });
      }

      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .update({
        'hasUnseenMessages.$currentUserId': false,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error marking messages as seen: $e");
      }
    }
  }

  Stream<QuerySnapshot> getUserActiveChats() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages({
    required String userId,
    required String anotherUserId,
  }) {
    String chatRoomId = getChatRoomId(userId, anotherUserId);

    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteMessage({
    required String userId,
    required String anotherUserId,
    required String docId,
  }) async {
    String chatRoomId = getChatRoomId(userId, anotherUserId);

    try {
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(docId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting message: $e");
      }
    }
  }
}
