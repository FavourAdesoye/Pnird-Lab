import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/setting/settings.dart';

class Notificationspage extends StatelessWidget { 
  const Notificationspage({super.key}); 

  @override
  Widget build(BuildContext context) { 
        return const _Notificationspage();
  }
} 

class _Notificationspage extends StatefulWidget { 
  
  const _Notificationspage(); 

  @override
  State<_Notificationspage> createState() => NotificationsPage();
} 

class NotificationsPage extends State<_Notificationspage> {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Notifications',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
             Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage())
                );
          },
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            NotificationItem(
              icon: Icons.person_outline,
              title: 'Comments on my posts',
            ),
            SizedBox(height: 16),
            NotificationItem(
              icon: Icons.notifications_outlined,
              title: 'Likes on my posts'),
              
            
            SizedBox(height: 16),
            NotificationItem(
              icon: Icons.notifications_outlined,
              title: 'Direct Messages',
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const NotificationItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}