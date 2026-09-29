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
