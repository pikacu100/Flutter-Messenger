import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/chat/chatpage.dart';
import 'package:flutter_messenger/screens/user/login.dart';
import 'package:flutter_messenger/services/encryption.dart';
import 'package:flutter_messenger/services/user.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: buildUserList(isDarkMode),
      ),
    );
  }

  Widget buildUserList(bool isDarkMode) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
            return const Center(child: Text('No users found'));
          }
          return ListView(
            children: snapshot.data!.docs
                .map((document) => buildUserListItem(document, isDarkMode))
                .toList(),
          );
        });
  }

  Widget buildUserListItem(DocumentSnapshot snapshot, bool isDarkMode) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    if (FirebaseAuth.instance.currentUser!.uid == data['uid']) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: isDarkMode ? 0 : 2,
      child: ListTile(
        title: Text(data['nickname'] ?? "Anonymous"),
        subtitle: Text(data['email'] ?? "No email"),
        leading: CircleAvatar(
          backgroundColor: isDarkMode ? Colors.white : Colors.black,
          child: Text(
            data['nickname'] != null && data['nickname'].isNotEmpty
                ? data['nickname'][0].toUpperCase()
                : "A",
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
                        receiverUserId: data['uid'],
                        receiverUserNickname: data['nickname'],
                      )));
        },
      ),
    );
  }
}
