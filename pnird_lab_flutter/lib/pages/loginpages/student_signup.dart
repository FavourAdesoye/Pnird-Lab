import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth.dart';
import '../../widgets/enhanced_text_form_field.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/password_strength_indicator.dart';
import 'email_verification_page.dart';

class StudentSignUpPage extends StatefulWidget {
  const StudentSignUpPage({super.key});

  @override
  _StudentSignUpPageState createState() => _StudentSignUpPageState();
}

class _StudentSignUpPageState extends State<StudentSignUpPage> {
  final _signUpFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> registerUser(String email, String password, String fullName,
      String mobileNumber, String role) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await Auth.signUp(email, password, fullName, role);
      
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Successful! Please verify your email to continue.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to email verification page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(email: email),
          ),
        );
      } else {
        // Show error with suggestions if available
        String errorMessage = result.message;
        if (result.data != null && result.data!['suggestions'] != null) {
          final suggestions = result.data!['suggestions'] as List<dynamic>;
          if (suggestions.isNotEmpty) {
            errorMessage += '\n\nSuggested usernames:\n${suggestions.join(', ')}';
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
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
      // Sets the background color of the screen
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
        child: Padding(
          // Adds padding around the content
          padding: const EdgeInsets.all(16.0),
          // Form widget to handle validation and submission
          child: Form(
            key: _signUpFormKey,
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo and welcome text
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logos/logophoto_Medium.png',
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
                      // "Sign Up" header
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Username input field
                      EnhancedTextFormField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hint: 'First and Last name',
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.trim().split(' ').length < 2) {
                            return 'Please enter your first and last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
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
                        hint: 'Create a strong password',
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
                      const SizedBox(height: 8),
                      // Password strength indicator
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _passwordController,
                        builder: (context, value, child) {
                          return PasswordStrengthIndicator(
                            password: value.text,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      // Mobile number input field
                      EnhancedTextFormField(
                        controller: _mobileNumberController,
                        label: 'Mobile Number',
                        hint: 'Enter your mobile number',
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Sign Up button
                      Center(
                        child: AuthButton(
                          text: 'Sign Up',
                          isLoading: _isLoading,
                          onPressed: () {
                            if (_signUpFormKey.currentState!.validate()) {
                              registerUser(
                                  _emailController.text.trim(),
                                  _passwordController.text,
                                  _fullNameController.text.trim(),
                                  _mobileNumberController.text.trim(),
                                  "student");
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      // "Already have an account? Login" text
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/student_login');
                          },
                          child: const Text(
                            "Already have an account? Login",
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }
}
