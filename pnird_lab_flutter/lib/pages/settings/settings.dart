 import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/current_user_profile_page.dart';
import 'package:pnirdlab/pages/edit_profile_screen.dart';
import 'package:pnirdlab/services/auth.dart';

class Setting extends StatelessWidget {
  final String userId;
  const Setting({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return _SettingPage();
  }
}

class _SettingPage extends StatefulWidget {
  const _SettingPage();

  @override
  SettingPageUI createState() => SettingPageUI();
}
class SettingPageUI extends State<_SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 245, 207, 40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ProfilePage(myuserId: '',)),
            );
          },
        ), 
    ), 
      body: Container( 
        padding: const EdgeInsets.all(10), 
        child: ListView( 
          children:  [ 
            const SizedBox(height: 40), 
            const Row( 
              children: [ 
                Icon( 
                  Icons.person, 
                  color: Colors.white, 
                ), 
                SizedBox( width: 10), 
                Text("Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))

              ]
            ), 
            const Divider(height: 20, thickness: 1), 
            const SizedBox(height: 10), 
            
        ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const ProfileEditScreen(userId: '',)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            trailing: const Icon(Icons.warning, color: Colors.red),
            onTap: () {
              _showConfirmationDialog(
                context,
                title: 'Delete Account',
                content: 'Are you sure you want to delete your account?',
                onConfirm: () {
                  Auth.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted.')),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              _showConfirmationDialog(
                context,
                title: 'Log Out',
                content: 'Are you sure you want to log out?',
                onConfirm: () { 
                  Auth.logout();
                  // Handle logout logic here
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out.')),
                  );
                },
              );
            },
          ),
        ],
      ),
    ));
  } 

   void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              onPressed: onConfirm,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}