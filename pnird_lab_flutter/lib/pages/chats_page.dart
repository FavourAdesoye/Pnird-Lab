import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/widgets/user_avatar.dart';
import 'package:pnirdlab/pages/message_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late Future<List<dynamic>> _chatUsersFuture;
  late String userId;
  bool isAdminUser = false;

  Future<List<dynamic>> fetchChatUsers() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('firebaseId') ?? '';
    isAdminUser = prefs.getBool('isAdmin') ?? false;

    final response = await http.get(
      Uri.parse("http://localhost:3000/api/messages/chats/$userId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load chat users");
    }
  }

  @override
  void initState() {
    super.initState();
    _chatUsersFuture = fetchChatUsers();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 11, 11),
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        title: Text("Chats"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: UserAvatar(filename: 'drKeen.jpg'),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _tabButton("Messages", true),
                _tabButton("Notifications", false),
              ],
            ),
            const SizedBox(height: 10),
            // Chat List
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _chatUsersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.amber));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No chats yet", style: TextStyle(color: Colors.grey)));
                  }

                  final chatUsers = snapshot.data!;
                  return ListView.builder(
                    itemCount: chatUsers.length,
                    itemBuilder: (context, index) {
                      final user = chatUsers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                        leading: CircleAvatar(
                          backgroundImage: (user['profilePicture'] != null && user['profilePicture'] != '')
                              ? NetworkImage(user['profilePicture'])
                              : AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
                        ),
                        title: Text(user['username'], style: TextStyle(color: Colors.white)),
                        subtitle: Text("Tap to message", style: TextStyle(color: Colors.grey)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagePage(
                                recipientId: user['_id'],
                                recipientName: user['username'],
                                isAdmin: isAdminUser,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool isActive) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isActive ? Colors.amber : const Color.fromARGB(255, 52, 52, 52),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20)),
        foregroundColor: WidgetStateProperty.all(
          isActive ? Colors.white : Colors.amber,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      ),
      onPressed: () {
        // TODO: switch between tabs if needed
      },
      child: Text(label, style: TextStyle(fontSize: 18)),
    );
  }
}
