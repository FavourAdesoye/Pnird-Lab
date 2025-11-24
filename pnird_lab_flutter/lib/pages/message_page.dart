import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/services/socket_service.dart';
import 'package:intl/intl.dart';
import 'package:pnirdlab/services/user_service.dart';
import 'package:pnirdlab/services/api_service.dart';

class MessagePage extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final bool isAdmin;


  const MessagePage({super.key, 
    required this.recipientId,
    required this.recipientName,
    required this.isAdmin,
   
  });
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final SocketService _socketService = SocketService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
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
      // Use centralized API service for consistent platform handling
      print('Loading message history for user: $userId');
      final url = '${ApiService.baseUrl}/messages/$userId';
      print('Message history URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.headers,
      );

      print('Message history response status: ${response.statusCode}');
      print('Message history response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> history = json.decode(response.body);
        print('Message history data: $history');
        
        // Filter messages to only include conversation with this recipient
        // and sort by timestamp (oldest first, so newest appear at bottom)
        final filteredMessages = history
            .where((m) => 
                (m["senderId"] == userId && m["recipientId"] == widget.recipientId) ||
                (m["senderId"] == widget.recipientId && m["recipientId"] == userId))
            .map((m) => {
              "from": m["senderId"],
              "message": m["message"],
              "timestamp": m["timestamp"] ?? m["createdAt"] ?? DateTime.now().toIso8601String(),
            })
            .toList();
        
        // Sort by timestamp (oldest first)
        filteredMessages.sort((a, b) {
          final timeA = DateTime.parse(a["timestamp"]).toLocal();
          final timeB = DateTime.parse(b["timestamp"]).toLocal();
          return timeA.compareTo(timeB);
        });
        
        setState(() {
          messages = filteredMessages;
        });
        
        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        print("Failed to load message history: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error loading message history: $e");
    }
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _initUser() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId") ?? "";
    print("User ID: $userId");
    _socketService.connect(userId);

    _socketService.socket.on("receive_message", (data) {
      // Only add message if it's from the current recipient
      if (data["senderId"] == widget.recipientId) {
        setState(() {
          messages.add({
            "from": data["senderId"],
            "message": data["message"],
            "timestamp": data["timestamp"] ?? DateTime.now().toIso8601String(),
          });
        });
        // Scroll to bottom when new message arrives
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
    
    // Listen for message_sent confirmation to update timestamp
    _socketService.socket.on("message_sent", (data) {
      // Update the last message with server timestamp if available
      if (messages.isNotEmpty && data["timestamp"] != null) {
        final lastIndex = messages.length - 1;
        if (messages[lastIndex]["message"] == data["message"]) {
          setState(() {
            messages[lastIndex]["timestamp"] = data["timestamp"];
          });
        }
      }
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
        const SnackBar(content: Text("You can't message yourself")),
      );
      return;
    }

    // Add message optimistically with client timestamp (will be updated with server timestamp)
    final tempTimestamp = DateTime.now().toIso8601String();
    setState(() {
      messages.add({
        "from": userId, 
        "message": msg,
        "timestamp": tempTimestamp,
      });
    });

    _socketService.sendMessage(userId, widget.recipientId, msg);

    _controller.clear();
    
    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _scrollController.dispose();
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: (recipientProfilePic != null && recipientProfilePic!.isNotEmpty)
                ? NetworkImage(recipientProfilePic!)
                : const AssetImage('assets/images/defaultprofilepic.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text('Chat with ${recipientUsername ?? widget.recipientName}',
                style: const TextStyle(
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
              controller: _scrollController,
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
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type any text here',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.purple),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                : const AssetImage('assets/images/defaultprofilepic.png')
                    as ImageProvider,
          ),
        if (!isUserMessage) const SizedBox(width: 8),
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
                      ? const Color(0xFFE0CB12)
                      : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message['message'] ?? '',
                  style: TextStyle(
                    color: isUserMessage
                        ? Colors.black
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(
                  message['timestamp'] != null
                      ? DateTime.parse(message['timestamp']).toLocal()
                      : DateTime.now(),
                ),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (isUserMessage) const SizedBox(width: 8),
        if (isUserMessage)
          CircleAvatar(
            radius: 16,
            backgroundImage: senderImage
                != null && senderImage.isNotEmpty
                ? NetworkImage(senderImage)
                : const AssetImage('assets/images/defaultprofilepic.png')
                    as ImageProvider,
          ),
      ],
    ),
  );
}
}