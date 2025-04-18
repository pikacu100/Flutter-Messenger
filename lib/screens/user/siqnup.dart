// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/services/createuser.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _showNextPasswordField = false;

  Future<void> signUp(bool google) async {
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
        final password = _passwordController.text;
        final email = _emailController.text;
        await CreateUser().createUserWithEmailAndPassword(email, password);
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacementNamed(context, '/authSig');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      wrongCredentialsDialog(e.code);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      if (kDebugMode) {
        print("Error signing up: $e");
      }
    }
  }

  void wrongCredentialsDialog(String error) {
    String errorMessage = "";
    if (error == 'user-not-found' || error == 'wrong-password') {
      errorMessage = "Incorrect email or password. Please try again.";
    } else if (error == 'passwords_do_not_match') {
      errorMessage = "Passwords do not match. Please try again.";
    } else if (error == 'fill_in_all_fields') {
      errorMessage = "Please fill in all required fields.";
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
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Sign up to connect with friends",
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
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _showNextPasswordField = true;
                            });
                          } else {
                            setState(() {
                              _showNextPasswordField = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Password",
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
                    const SizedBox(height: 16),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      offset:
                          _showNextPasswordField ? Offset.zero : const Offset(0, 1),
                      child: _showNextPasswordField
                          ? Container(
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
                                key: const ValueKey('confirmPasswordField'),
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: "Confirm Password",
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
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          if (_passwordController.text ==
                              _confirmPasswordController.text) {
                            signUp(false);
                          } else {
                            wrongCredentialsDialog('passwords_do_not_match');
                          }
                        } else {
                          wrongCredentialsDialog('fill_in_all_fields');
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
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                        onTap: () => signUp(true),
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
                                "Sign up with Google",
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
                          "Already have an account?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            "Log In",
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