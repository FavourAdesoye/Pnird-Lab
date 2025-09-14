import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth.dart';
import '../../widgets/enhanced_text_form_field.dart';
import '../../widgets/auth_button.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _studentLoginformKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> loginUser(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await Auth.login(email, password);
      
      if (result.success && result.data != null) {
        final data = result.data!;
        final role = data['role'] as String;
        
        // Save login state
        await Auth.saveLoginState(
          data['userId'] as String,
          data['username'] as String,
          role,
          data['profilePicture'] as String? ?? '',
        );

        // Redirect based on user role
        if (role == "student") {
          Navigator.pushNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are not registered as a student in our database'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushNamed(context, '/staff_login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Ensures the UI avoids areas like the notch on iOS devices
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Makes the content scrollable to prevent overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _studentLoginformKey,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  // Decoration for rounded corners and shadow
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  // Column to arrange widgets vertically
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and welcome text
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logos/logophoto_Medium.png', // Logo asset
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Hello Student!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome back to our app',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // "Login" header
                      const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Email input field
                      EnhancedTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'example@vsu.edu',
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Enhanced email validation
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      // Password input field
                      EnhancedTextFormField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: _obscurePassword,
                        showToggle: true,
                        enabled: !_isLoading,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must have at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Forgot Password text
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Handle forgot password logic here
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Login button
                      Center(
                        child: AuthButton(
                          text: 'Login',
                          isLoading: _isLoading,
                          onPressed: () {
                            if (_studentLoginformKey.currentState!.validate()) {
                              // Get values from controllers
                              String email = _emailController.text.trim();
                              String password = _passwordController.text.trim();

                              // Call login function with the variables
                              loginUser(email, password);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // "Don't have an account? Sign up" text
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/student_signup');
                          },
                          child: const Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

bool performLogin(String email, String password) {
  if (email == 'student@example.com' && password == 'password123') {
    // Login successful
    return true;
  } else {
    // Login failed
    return false;
  }
}
