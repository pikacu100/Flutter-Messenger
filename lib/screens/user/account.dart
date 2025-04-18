import 'package:flutter/material.dart';
import 'package:flutter_messenger/style.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
    );
  }
}