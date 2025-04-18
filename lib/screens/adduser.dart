import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_messenger/services/encryption.dart';
import 'package:flutter_messenger/style.dart';

class AddUserPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const AddUserPage({super.key, required this.onThemeChanged});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
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

  Future<void> addUser(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friends')
        .doc(data['uid'])
        .set({
      'nickname': data['nickname'],
      'email': data['email'],
      'uid': data['uid'],
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User added to your friends list")));
    }).catchError((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to add user: $error")));
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add User'),
        titleTextStyle: FontStyles().appBarStyle(isDarkMode),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          children: [
            Expanded(child: buildUserList(isDarkMode)),
          ],
        ),
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
        trailing: const Icon(Icons.add, color: Colors.blue),
        onTap: () async {
          addUser(data);
          Navigator.pop(context);
        },
      ),
    );
  }
}
