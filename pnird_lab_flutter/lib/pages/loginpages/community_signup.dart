import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../../widgets/enhanced_text_form_field.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/password_strength_indicator.dart';
import '../../widgets/auth_page_shell.dart';
import 'email_verification_page.dart';

class CommunitySignUpPage extends StatefulWidget {
  const CommunitySignUpPage({super.key});

  @override
  _CommunitySignUpPageState createState() => _CommunitySignUpPageState();
}

class _CommunitySignUpPageState extends State<CommunitySignUpPage> {
  final _signUpFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> registerUser(String email, String password, String fullName, String role) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await Auth.signUp(email, password, fullName, role);

      if (result.success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created! Check your email, open the verification link, then log in.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 6),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(email: email),
          ),
        );
      } else {
        String errorMessage = result.message;
        if (result.data != null && result.data!['suggestions'] != null) {
          final suggestions = result.data!['suggestions'] as List<dynamic>;
          if (suggestions.isNotEmpty) {
            errorMessage += '\n\nSuggested usernames:\n${suggestions.join(', ')}';
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = authPrimaryText(context);
    final accent = authAccent(context);

    return AuthPageShell(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _signUpFormKey,
            child: Center(
              child: AuthCard(
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
                          Text(
                            'Hello Community Member!',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome to our app',
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        color: accent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
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
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _passwordController,
                      builder: (context, value, child) {
                        return PasswordStrengthIndicator(
                          password: value.text,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
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
                              'community',
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/community_login');
                        },
                        child: const Text(
                          'Already have an account? Login',
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
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
