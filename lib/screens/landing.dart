import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_messenger/screens/chat/chatpage.dart';
import 'package:flutter_messenger/screens/friends.dart';
import 'package:flutter_messenger/screens/user/account.dart';
import 'package:flutter_messenger/screens/user/login.dart';
import 'package:flutter_messenger/services/chat/chat_service.dart';
import 'package:flutter_messenger/services/encryption.dart';
import 'package:flutter_messenger/services/user.dart';
import 'package:flutter_messenger/style.dart';

class LandingPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const LandingPage({super.key, required this.onThemeChanged});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String encryptedMessage = "";
  String messageToSend = "Nigger";
  String decryptedMessage = "";
  bool isDarkModeEnable = true;

  Future<void> encryptMessage(String uid) async {
    setState(() {
      encryptedMessage = EncryptionService.encrypt(messageToSend, uid);
    });
  }

  Future<void> decryptMessage(String uid) async {
    setState(() {
      decryptedMessage = EncryptionService.decrypt(encryptedMessage, uid);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flutter Messenger'),
        titleTextStyle: FontStyles().appBarStyle(isDarkMode),
        actions: [
          IconButton(
              onPressed: () => UserData().signUserOut().then((_) =>
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Loginpage()))),
              icon: const Icon(Icons.logout)),
        ],
        leading: IconButton(
          icon: isDarkModeEnable
              ? const Icon(Icons.dark_mode)
              : const Icon(Icons.light_mode),
          onPressed: () {
            setState(() {
              isDarkModeEnable = !isDarkModeEnable;
              widget.onThemeChanged(
                isDarkModeEnable ? ThemeMode.dark : ThemeMode.light,
              );
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountPage())),
                      style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          backgroundColor: const Color(0xFF0077FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: const Center(child: Text("Account"))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FriendsPage(
                                    onThemeChanged: widget.onThemeChanged,
                                  ))),
                      style: ElevatedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          backgroundColor: const Color(0xFF0077FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: const Center(child: Text("Your Friends"))),
                ),
              ],
            ),
            Expanded(child: buildActiveChats(isDarkMode)),
          ],
        ),
      ),
    );
  }

  Widget buildActiveChats(bool isDarkMode) {
  final ChatService _chatService = ChatService();
  
  return StreamBuilder(
    stream: _chatService.getUserActiveChats(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        );
      }
      
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No active chats'));
      }
      
      // Sort documents in Dart code by lastMessageTime
      final sortedDocs = snapshot.data!.docs.toList()
        ..sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          
          final aTime = aData['lastMessageTime'] as Timestamp?;
          final bTime = bData['lastMessageTime'] as Timestamp?;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          
          return bTime.compareTo(aTime);
        });
      
      return ListView(
        children: sortedDocs
            .map((document) => buildChatListItem(document, isDarkMode))
            .toList(),
      );
    },
  );
}

  Widget buildChatListItem(DocumentSnapshot snapshot, bool isDarkMode) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  List<dynamic> participants = data['participants'] ?? [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ChatService chatService = ChatService(); // Create instance

  String? otherUserId;
  for (var userId in participants) {
    if (userId != currentUserId) {
      otherUserId = userId;
      break;
    }
  }
  
  if (otherUserId == null) return const SizedBox.shrink();
  
  bool hasUnseenMessages = false;
  if (data.containsKey('hasUnseenMessages')) {
    Map<String, dynamic> unseenMap = data['hasUnseenMessages'];
    hasUnseenMessages = unseenMap[currentUserId] ?? false;
  }
  
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get(),
    builder: (context, userSnapshot) {
      if (!userSnapshot.hasData) {
        return const SizedBox.shrink();
      }
      
      Map<String, dynamic> userData = 
          userSnapshot.data!.data() as Map<String, dynamic>;
      
      String nickname = userData['nickname'] ?? "Anonymous";
      String lastMessage = "";
      
      if (data.containsKey('lastMessage')) {
        String encryptedLastMessage = data['lastMessage'];
        lastMessage = EncryptionService.decrypt(
            encryptedLastMessage, 
            chatService.getChatRoomId(currentUserId, otherUserId!)
        );
 
        if (lastMessage.length > 30) {
          lastMessage = "${lastMessage.substring(0, 27)}...";
        }
      }
      
      return Card(
        elevation: isDarkMode ? 0 : 2,
        child: ListTile(
          title: Row(
            children: [
              Text(nickname),
              if (hasUnseenMessages)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(lastMessage),
          leading: CircleAvatar(
            backgroundColor: isDarkMode ? Colors.white : Colors.black,
            child: Text(
              nickname.isNotEmpty ? nickname[0].toUpperCase() : "A",
              style: TextStyle(
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserId: otherUserId!, 
                  receiverUserNickname: nickname,
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
}