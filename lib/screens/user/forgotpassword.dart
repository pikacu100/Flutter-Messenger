import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> sendPasswordResetEmail() async {
    if (_emailController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _emailController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password reset email sent!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
          backgroundColor: Colors.green,
        ));

        Navigator.pop(context); 
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No account found with this email.';
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your email address.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Colors.red,
      ));
    }
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
                      "Forgot Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your email to receive a password reset link",
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
                          hintText: "Email Address",
                          hintStyle: const TextStyle(color: Colors.black38),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: sendPasswordResetEmail,
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
                        "Send Reset Link",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Back to Login",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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