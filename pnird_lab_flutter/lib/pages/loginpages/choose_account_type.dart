import 'package:flutter/material.dart';

class AccountTypeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  AccountTypeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class ChooseAccountTypePage extends StatefulWidget {
  const ChooseAccountTypePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChooseAccountTypePageState createState() => _ChooseAccountTypePageState();
}

class _ChooseAccountTypePageState extends State<ChooseAccountTypePage> {
  String selectedAccountType = '';

  void navigateToSignUp() {
    if (selectedAccountType == 'Student') {
      Navigator.pushNamed(context, '/student_signup');
    } else if (selectedAccountType == 'Staff') {
      Navigator.pushNamed(context, '/staff_signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                          'Hello!',
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
                    'Choose account type',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AccountTypeButton(
                    label: 'Student',
                    onPressed: () {
                      Navigator.pushNamed(context, '/student_login');
                    },
                  ),
                  const SizedBox(height: 40),
                  AccountTypeButton(
                    label: 'Staff',
                    onPressed: () {
                      Navigator.pushNamed(context, '/staff_login');
                    },
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
