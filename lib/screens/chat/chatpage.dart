import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/services/chat/chat_service.dart';
import 'package:flutter_messenger/services/encryption.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserNickname;
  final String receiverUserId;
  const ChatPage({
    super.key,
    required this.receiverUserNickname,
    required this.receiverUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        message: _messageController.text,
        receiverId: widget.receiverUserId,
      );
      _messageController.clear();
    }
  }

  String formatTimeStamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.hour}:${dateTime.minute}';
  }

  String decryptMessage(
      String encryptedMessage, String userId, String anotherUserId) {
    List<String> chatIds = [userId, anotherUserId];
    chatIds.sort();
    String chatRoomId = chatIds.join('_');
    return EncryptionService.decrypt(encryptedMessage, chatRoomId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(widget.receiverUserNickname),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.grey.shade900,
        ),
        surfaceTintColor:
            isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
        leading: IconButton(
          icon: const Icon(
            Icons.navigate_before,
            size: 25,
          ),
          color: isDarkMode ? Colors.white : Colors.grey.shade900,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            userId: widget.receiverUserId,
            anotherUserId: FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.blue,
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No messages yet, Start chatting!'));
          }
          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    var isMe = data['senderId'] == FirebaseAuth.instance.currentUser!.uid;
    var alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    var color = isMe ? Colors.blue[100] : Colors.grey[300];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                decryptMessage(
                  data['message'],
                  FirebaseAuth.instance.currentUser!.uid,
                  widget.receiverUserId,
                ),
                style: TextStyle(color: Colors.grey.shade900),
              ),
            ),
            Text(
              formatTimeStamp(data['timestamp']),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Send message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
