import 'package:flutter/material.dart';

/// Shared theme-aware chrome for login / signup / account-type screens.
class AuthPageShell extends StatelessWidget {
  final Widget child;
  final bool showBack;

  const AuthPageShell({
    super.key,
    required this.child,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffold = isDark ? Colors.black : theme.scaffoldBackgroundColor;
    final appBarBg = isDark ? Colors.grey[900] : theme.appBarTheme.backgroundColor;
    final iconColor = isDark ? Colors.white : theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: scaffold,
      appBar: showBack
          ? AppBar(
              backgroundColor: appBarBg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: iconColor),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(child: child),
    );
  }
}

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
            spreadRadius: isDark ? 5 : 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        border: isDark ? null : Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}

Color authPrimaryText(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white : const Color(0xFF1A1A1A);
}

Color authAccent(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? Colors.yellow
      : const Color(0xFFB8860B);
}

Future<String?> showResetPasswordDialog(
  BuildContext context, {
  String initialEmail = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _ResetPasswordDialog(initialEmail: initialEmail),
  );
}

class _ResetPasswordDialog extends StatefulWidget {
  final String initialEmail;

  const _ResetPasswordDialog({required this.initialEmail});

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = authPrimaryText(context);

    return AlertDialog(
      backgroundColor: isDark ? Colors.grey[900] : theme.colorScheme.surface,
      title: Text('Reset password', style: TextStyle(color: textColor)),
      content: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          hintText: 'Enter the email for your account',
          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _emailController.text.trim()),
          child: const Text('Send link'),
        ),
      ],
    );
  }
}
