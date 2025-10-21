import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/services/socket_service.dart';
import 'package:intl/intl.dart';
import 'package:pnirdlab/model/user_model.dart';
import 'package:pnirdlab/services/user_service.dart';

class MessagePage extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final bool isAdmin;


  const MessagePage({
    required this.recipientId,
    required this.recipientName,
    required this.isAdmin,
   
  });
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final SocketService _socketService = SocketService();
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  String? recipientUsername = "";
  String? recipientProfilePic = "";
  String? senderUsername = "";
  String? senderProfilePic = ""; 


  String userId = "";

  @override
  void initState() {
    super.initState();
    _initUser();
    fetchSenderUser();
    fetchRecipientUser();
  }  
  Future<void> loadMessageHistory() async {
    try {
      // Use a more flexible API URL - you may need to update this based on your deployment
      final baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
      // For iOS simulator use: 'http://localhost:3000'
      // For production use your actual server URL
      
      print('Loading message history for user: $userId');
      final url = '$baseUrl/api/messages/$userId';
      print('Message history URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Message history response status: ${response.statusCode}');
      print('Message history response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> history = json.decode(response.body);
        print('Message history data: $history');
        setState(() {
          messages = history.map((m) => {
            "from": m["senderId"],
            "message": m["message"],
            "timestamp": m["timestamp"] ?? DateTime.now().toIso8601String(),
          }).toList();
        });
      } else {
        print("Failed to load message history: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error loading message history: $e");
    }
  }

  Future<void> _initUser() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId") ?? "";
    print("User ID: $userId");
    _socketService.connect(userId);

    _socketService.socket.on("receive_message", (data) {
      setState(() {
        messages.add({
          "from": data["senderId"],
          "message": data["message"],
          "timestamp": data["timestamp"] ?? DateTime.now().toIso8601String(),
        });
        
      });

      
    });
  //   _socketService.socket.on("new_notification", (data) {
  // print("New notification received: $data");

  // // Optional: You can show a snackbar or toast
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(content: Text(data['message'] ?? 'You have a new notification')),
  // );

  // You can also refresh your notification list if you're saving notifications in a list
  // setState(() { notifications.add(Notification.fromJson(data)); });
// });

    await loadMessageHistory(); 
    
  }
  
  Future<void> fetchRecipientUser() async {
  try {
    
    final recipient = await UserService().fetchUserProfile(widget.recipientId);
    setState(() {
      recipientUsername = recipient.username;
      recipientProfilePic = recipient.profilePicture;
    });
  } catch (e) {
    print("Error fetching recipient: $e");
  }
}

Future<void> fetchSenderUser() async {
  try {
    userId = await SharedPreferences.getInstance().then((prefs) => prefs.getString("userId") ?? "");
    final sender = await UserService().fetchUserProfile(userId);
    setState(() {
      senderUsername = sender.username;
      senderProfilePic = sender.profilePicture;
    });
  } catch (e) {
    print("Error fetching sender: $e");
  }
}


  void _sendMessage() {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    if (!widget.isAdmin && widget.recipientId == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can't message yourself")),
      );
      return;
    }

    _socketService.sendMessage(userId, widget.recipientId, msg);

    setState(() {
      messages.add({"from": userId, "message": msg});
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Row(
          children: [
            CircleAvatar(
  radius: 20,
  backgroundImage: (recipientProfilePic != null && recipientProfilePic!.isNotEmpty)?
    NetworkImage(recipientProfilePic!)
    : AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
),

            SizedBox(width: 10),
            Text('Chat with ${recipientUsername ?? widget.recipientName}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                )),
            
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessageBubble(messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type any text here',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.purple),
                  onPressed: () =>
                    _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget buildMessageBubble(Map<String, dynamic> message) {
  bool isUserMessage = message['from'] == userId;

  final senderImage = senderProfilePic ;
  final recipientImage = recipientProfilePic;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
    child: Row(
      mainAxisAlignment:
          isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUserMessage )
          CircleAvatar(
            radius: 16,
            backgroundImage: recipientImage
                != null && recipientImage.isNotEmpty
                ? NetworkImage(recipientImage)
                : AssetImage('assets/images/defaultprofilepic.png')
                    as ImageProvider,
          ),
        if (!isUserMessage) SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: isUserMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUserMessage
                      ? Color(0xFFE0CB12)
                      : Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message['message'] ?? '',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(
                  message['timestamp'] != null
                      ? DateTime.parse(message['timestamp'])
                      : DateTime.now(),
                ),
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        if (isUserMessage) SizedBox(width: 8),
        if (isUserMessage)
          CircleAvatar(
            radius: 16,
            backgroundImage: senderImage
                != null && senderImage.isNotEmpty
                ? NetworkImage(senderImage)
                : AssetImage('assets/images/defaultprofilepic.png')
                    as ImageProvider,
          ),
      ],
    ),
  );
}
}