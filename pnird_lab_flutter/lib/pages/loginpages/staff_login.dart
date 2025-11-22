import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth.dart';
import '../../widgets/enhanced_text_form_field.dart';
import '../../widgets/auth_button.dart';

class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StaffLoginPageState createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final _staffLoginformKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // Add loading indicator

  Future<void> loginUser(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await Auth.login(email, password);
      
      if (result.success && result.data != null) {
        final data = result.data!;
        final role = data['role'] as String;
        
        // Get Firebase UID from current user
        final firebaseUID = FirebaseAuth.instance.currentUser?.uid ?? '';
        
        // Save login state
        await Auth.saveLoginState(
          data['userId'] as String,
          data['username'] as String,
          role,
          data['profilePicture'] as String? ?? '',
          firebaseUID,
        );

        // Redirect based on user role
        if (role == "staff") {
          Navigator.pushNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You are not registered as a staff in our database'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushNamed(context, '/student_login');
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _staffLoginformKey,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logos/logophoto_Medium.png',
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Hello Staff!',
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
                      const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      EnhancedTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'example@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      EnhancedTextFormField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Must have at least 8 characters',
                        obscureText: _obscurePassword,
                        showToggle: true,
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
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_staffLoginformKey.currentState!.validate()) {
                              // Get values from controllers
                              String email = _emailController.text.trim();
                              String password = _passwordController.text.trim();

                              // Call login function with the variables
                              loginUser(email, password);
                            }
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
                      Center(
                        child: AuthButton(
                          text: 'Login',
                          onPressed: () {
                            if (_staffLoginformKey.currentState!.validate()) {
                              String email = _emailController.text;
                              String password = _passwordController.text;
                              loginUser(email, password);
                            }
                          },
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to the sign-up page
                            Navigator.pushNamed(context, '/staff_signup');
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

