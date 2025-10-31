import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/pages/message_page.dart';
import 'package:pnirdlab/pages/notification_page.dart';
import 'package:pnirdlab/pages/api_test_page.dart';
class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late Future<List<dynamic>> _chatUsersFuture;
  late String userId;
  bool isAdminUser = false;
  String? currentUserProfilePicture;
  int _selectedTabIndex = 0;

  Future<List<dynamic>> fetchChatUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseId = prefs.getString('firebaseId') ?? '';
      final mongoUserId = prefs.getString('userId') ?? '';
      isAdminUser = prefs.getBool('isAdmin') ?? false;

      print('Firebase ID: $firebaseId');
      print('MongoDB User ID: $mongoUserId');

      if (firebaseId.isEmpty) {
        throw Exception("User not logged in. Please log in again.");
      }

      // Use a more flexible API URL - you may need to update this based on your deployment
      final baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
      // For iOS simulator use: 'http://localhost:3000'
      // For production use your actual server URL
      
      final url = "$baseUrl/api/messages/chats/$firebaseId";
      print('Fetching from URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed data: $data');
        return data;
      } else {
        throw Exception("Failed to load chat users: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error fetching chat users: $e');
      throw Exception("Network error: $e");
    }
  }

  Future<void> fetchCurrentUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final mongoUserId = prefs.getString('userId');
    
    if (mongoUserId != null) {
      try {
        final response = await http.get(
          Uri.parse("http://localhost:3000/api/users/id/$mongoUserId"),
        );
        
        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          setState(() {
            currentUserProfilePicture = userData['profilePicture'];
          });
        }
      } catch (e) {
        // Handle error silently
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _chatUsersFuture = fetchChatUsers();
    fetchCurrentUserProfile();
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
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ApiTestPage()),
              );
            },
            tooltip: 'Debug API',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: (currentUserProfilePicture != null && currentUserProfilePicture!.isNotEmpty)
                  ? NetworkImage(currentUserProfilePicture!)
                  : AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image loading error silently
              },
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          children: [
            // Tabs
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton("Messages", 0),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _tabButton("Notifications", 1),
                  ),
                ],
              ),
            ),
            // Content based on selected tab
            Expanded(
              child: _selectedTabIndex == 0 ? _buildMessagesTab() : _buildNotificationsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int tabIndex) {
    bool isActive = _selectedTabIndex == tabIndex;
    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isActive ? Colors.yellow : Colors.grey[800],
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        foregroundColor: WidgetStateProperty.all(
          isActive ? Colors.black : Colors.white,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedTabIndex = tabIndex;
        });
      },
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMessagesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<List<dynamic>>(
        future: _chatUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _chatUsersFuture = fetchChatUsers();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    "No chats yet",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Start a conversation with someone!",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final chatUsers = snapshot.data!;
          return ListView.builder(
            itemCount: chatUsers.length,
            itemBuilder: (context, index) {
              final user = chatUsers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: (user['profilePicture'] != null && user['profilePicture'] != '')
                        ? NetworkImage(user['profilePicture'])
                        : const AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      // Handle image loading error silently
                    },
                  ),
                  title: Text(
                    user['username'] ?? 'Unknown User',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Tap to message",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.yellow, size: 16),
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return NotificationsPage();
  }
}
