import 'package:flutter/material.dart';
import 'package:pnirdlab/widgets/post_card.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserAndNotifications();
  }

  Future<void> loadUserAndNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    print(userId);
    if (userId != null) {
      notifications = await NotificationService.fetchNotifications(userId!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: notifications.isEmpty
          ? Center(child: Text("No notifications yet"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                print(notif);
                return ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text(notif['message']),
                  subtitle: Text(
  notif['timestamp'] != null
      ? formattedDateTime(DateTime.parse(notif['timestamp']))
      : formattedDateTime(DateTime.parse(notif['createdAt'])),
),
                  onTap: () {
                    // Todo: Navigate to the appropriate page based on notification type
                    if (false) {
                      
                    } else if (notif['type'] == 'message') {
                      Navigator.pushNamed(context, '/messages');
                    }
                  },
                );
              },
            ),
    );
  }
}
