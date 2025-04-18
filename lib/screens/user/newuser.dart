// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/landing.dart';
import 'package:flutter_messenger/services/user.dart';

class NewUserPage extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const NewUserPage({super.key, required this.onThemeChanged});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final TextEditingController _nicknameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
        : [const Color(0xFF00C6FF), const Color(0xFF0078FF)];
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Flutter Messenger!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please set up your profile.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nicknameController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Your nickname",
                    hintStyle: const TextStyle(color: Colors.black38),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF0078FF),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_nicknameController.text.isNotEmpty) {
                          if (mounted) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Color(0xFF00C6FF),
                                  ));
                                });
                          }

                          await UserData().createUserDoc();
                          await UserData()
                              .updateUserNickname(_nicknameController.text);
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LandingPage(
                                        onThemeChanged: widget.onThemeChanged,
                                      )));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "Please fill in all fields",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.red,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0078FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    ));
  }
}
