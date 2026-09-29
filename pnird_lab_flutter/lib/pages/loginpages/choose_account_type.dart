import 'package:flutter/material.dart';
import 'package:pnirdlab/widgets/auth_page_shell.dart';

class AccountTypeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AccountTypeButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
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
            style: TextStyle(
              color: authAccent(context),
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
  void _goToLogin(String accountType) {
    if (accountType == 'Community') {
      Navigator.pushNamed(context, '/community_login');
    } else if (accountType == 'Staff') {
      Navigator.pushNamed(context, '/staff_login');
    }
  }

  void _goToSignUp(String accountType) {
    if (accountType == 'Community') {
      Navigator.pushNamed(context, '/community_signup');
    } else if (accountType == 'Staff') {
      Navigator.pushNamed(context, '/staff_signup');
    }
  }

  Future<void> _pickAccountType({required bool forLogin}) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Community', style: TextStyle(color: authPrimaryText(ctx))),
              onTap: () => Navigator.pop(ctx, 'Community'),
            ),
            ListTile(
              title: Text('Staff', style: TextStyle(color: authPrimaryText(ctx))),
              onTap: () => Navigator.pop(ctx, 'Staff'),
            ),
          ],
        ),
      ),
    );

    if (choice == null || !mounted) return;
    if (forLogin) {
      _goToLogin(choice);
    } else {
      _goToSignUp(choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = authPrimaryText(context);
    final accent = authAccent(context);

    return AuthPageShell(
      showBack: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        'Hello!',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome back to our app',
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
                  'Choose account type',
                  style: TextStyle(
                    color: accent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                AccountTypeButton(
                  label: 'Community',
                  onPressed: () => _goToLogin('Community'),
                ),
                const SizedBox(height: 16),
                AccountTypeButton(
                  label: 'Staff',
                  onPressed: () => _goToLogin('Staff'),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => _pickAccountType(forLogin: false),
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        color: Colors.blue,
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
    );
  }
}
