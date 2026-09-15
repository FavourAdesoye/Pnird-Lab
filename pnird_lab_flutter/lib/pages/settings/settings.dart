import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/edit_profile_screen.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:pnirdlab/pages/settings/privacy.dart';
import 'package:pnirdlab/services/auth.dart';

class Setting extends StatelessWidget {
  final String userId;
  const Setting({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _SettingPage(userId: userId);
  }
}

class _SettingPage extends StatefulWidget {
  final String userId;
  const _SettingPage({required this.userId});

  @override
  SettingPageUI createState() => SettingPageUI();
}

class SettingPageUI extends State<_SettingPage> {
  bool _deletingAccount = false;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _resolveUserId();
  }

  Future<void> _resolveUserId() async {
    if (_userId.isNotEmpty) return;
    final fromSession = await Auth.getUserId();
    if (!mounted) return;
    if (fromSession != null && fromSession.isNotEmpty) {
      setState(() => _userId = fromSession);
    }
  }

  Future<void> _goToLoggedOutRoot() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ChooseAccountTypePage()),
      (_) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This permanently deletes your login, profile, messages, notifications, '
          'chatbot history, and posts you created. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deletingAccount = true);
    final result = await Auth.deleteAccount();
    if (!mounted) return;
    setState(() => _deletingAccount = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account was deleted.')),
      );
      await _goToLoggedOutRoot();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );

    if (confirmed != true) return;
    await Auth.logout();
    if (!mounted) return;
    await _goToLoggedOutRoot();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 245, 207, 40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SizedBox(height: 40),
          const Row(
            children: [
              Icon(Icons.person, color: Colors.white),
              SizedBox(width: 10),
              Text('Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20, thickness: 1),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: userId.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileEditScreen(userId: userId),
                      ),
                    );
                  },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            trailing: _deletingAccount
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.warning, color: Colors.red),
            onTap: _deletingAccount ? null : _deleteAccount,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            trailing: const Icon(Icons.exit_to_app),
            onTap: _logout,
          ),
          if (userId.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Session is missing a user id. Log out and sign in again to edit your profile or delete your account.',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }
}
