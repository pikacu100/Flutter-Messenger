// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/screens/user/forgotpassword.dart';
import 'package:flutter_messenger/services/createuser.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _MessengerLoginPageState();
}

class _MessengerLoginPageState extends State<Loginpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> login(bool google) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child: CircularProgressIndicator(
            color: Color(0xFF00C6FF),
          ));
        });

    try {
      if (google) {
        UserCredential userCredential = await CreateUser().signInWithGoogle();
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushReplacementNamed(context, '/authSig');
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushReplacementNamed(context, '/authLog');
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          await Navigator.pushReplacementNamed(context, '/authLog');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      wrongCredentialsDialog(e.code);
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      if (kDebugMode) {
        print("Error logging in: $e");
      }
    }
  }

  void wrongCredentialsDialog(String error) {
    String errorMessage = "";
    if (error == 'user-not-found' || error == 'wrong-password') {
      errorMessage = "Incorrect email or password. Please try again.";
    } else {
      errorMessage = "An error occurred. Please try again later.";
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(errorMessage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )),
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Flutter Messenger",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign in to connect with friends",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                        controller: _emailController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF0078FF),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF0078FF),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          login(false);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please fill in all fields"),
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
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPassword()));
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white38,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Or continue with",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white38,
                            thickness: 1,
                          ),
                        ),
                      ],
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
                      child: InkWell(
                        onTap: () => login(true),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_logo.webp',
                                height: 24,
                                repeat: ImageRepeat.noRepeat,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signup');
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
