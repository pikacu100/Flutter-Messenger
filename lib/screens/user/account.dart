import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_messenger/services/user.dart';
import 'package:flutter_messenger/style.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController _nicknameController = TextEditingController();
  String nickname = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await UserData().getUserData().then((userData) {
      setState(() {
        nickname = userData != null
            ? userData['nickname'] ?? "No nickname"
            : "No nickname";
      });
    }).catchError((error) {
      print("Error loading user data: $error");
    });

    setState(() {
      _nicknameController.text = nickname;
    });
  }

  void _changeUserInfo() {
    UserData().updateUserDisplayName(nickname);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        titleTextStyle: FontStyles().appBarStyle(isDarkMode),
        title: const Text('Account'),
        surfaceTintColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: CircleAvatar(
              backgroundColor:
                  isDarkMode ? Colors.white : Colors.grey.shade900,
              child: Text(
                nickname.isNotEmpty ? nickname[0].toUpperCase() : "A",
                style: TextStyle(
                  fontSize: 30,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          buildNicknameField(isDarkMode: isDarkMode),
        ],
      ),
    );
  }

  Widget buildNicknameField({required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nickname",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade800),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: _nicknameController,
            maxLength: 30,
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.grey.shade100 : Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              counterText: "",
              contentPadding: EdgeInsets.zero,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                nickname = value;
              });
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 2000), () {
                _changeUserInfo();
              });
            },
          ),
        ],
      ),
    );
  }
}
