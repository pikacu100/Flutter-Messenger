import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/adduser.dart';
import 'package:flutter_messenger/screens/chat/chatpage.dart';
import 'package:flutter_messenger/services/user.dart';
import 'package:flutter_messenger/style.dart';

class FriendsPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const FriendsPage({super.key, required this.onThemeChanged});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  void _showMessageOptionsAtPosition(
    BuildContext context,
    Offset position,
    String snapshotId,
  ) {
    final RelativeRect popupPosition = RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + 1,
      position.dy + 1,
    );

    showMenu(
      context: context,
      position: popupPosition,
      surfaceTintColor: Colors.grey.shade900,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      items: [
        const PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete),
              SizedBox(width: 8),
              Text('Remove Friend'),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'remove') {
        await UserData().removeFriend(snapshotId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        titleTextStyle: FontStyles().appBarStyle(isDarkMode),
        title: const Text('Friends'),
        surfaceTintColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddUserPage(
                            onThemeChanged: widget.onThemeChanged,
                          )));
            },
            icon: const Icon(
              Icons.add,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: buildFriendsList(isDarkMode),
      ),
    );
  }

  Widget buildFriendsList(bool isDarkMode) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('friends')
            .snapshots(),
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
            return const Center(child: Text('No friends found'));
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
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        _showMessageOptionsAtPosition(
          context,
          details.globalPosition,
          snapshot.id,
        );
      },
      child: Card(
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
                          receiverUserNickname: data['nickname'] ?? "Anonymous",
                        )));
          },
        ),
      ),
    );
  }
}
