import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_messenger/model/message.dart';
import 'package:flutter_messenger/services/encryption.dart';

class ChatService {
  Future<void> sendMessage(
      {required String receiverId, required String message}) async {
    final String senderId = FirebaseAuth.instance.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    List<String> chatIds = [senderId, receiverId];
    chatIds.sort();
    String chatRoomId = chatIds.join('_');

    final String encryptedMessage =
        EncryptionService.encrypt(message, chatRoomId);
    Message newMessage = Message(
      message: encryptedMessage,
      senderId: senderId,
      receiverId: receiverId,
      timestamp: timestamp,
    );

    try {
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Stream<QuerySnapshot> getMessages(
      {required String userId, required String anotherUserId}) {
    List<String> chatIds = [userId, anotherUserId];
    chatIds.sort();
    String chatRoomId = chatIds.join('_');

    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
