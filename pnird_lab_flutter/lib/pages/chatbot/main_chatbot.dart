import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chathome extends StatefulWidget {
  const Chathome({super.key});

  @override
  State<Chathome> createState() => _ChatPageState();
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _ChatPageState extends State<Chathome> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text('Learn more about the Lab',
              style: TextStyle(color: Colors.white)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(Message(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _textController.clear();
      _isLoading = true;
    });

    _getChatResponse(text);
  }

  Future<void> _getChatResponse(String userMessage) async {
    try {
      // Use the correct base URL depending on the platform
      String baseUrl;
      if (kIsWeb) {
        baseUrl = 'http://localhost:3000';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Android emulator uses 10.0.2.2 to reach host machine's localhost
        baseUrl = 'http://10.0.2.2:3000';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS simulator can use localhost
        baseUrl = 'http://localhost:3000';
      } else {
        // Desktop or other platforms
        baseUrl = 'http://localhost:3000';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/ask'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botMessage = data['answer'] ?? 'Sorry, I could not process your request.';
        
        if (mounted) {
          setState(() {
            _messages.add(Message(
              text: botMessage,
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _messages.add(Message(
              text: 'Sorry, I encountered an error. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
            ));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Chatbot error: $e');
      if (mounted) {
        setState(() {
          String errorMessage;
          if (e.toString().contains('timeout')) {
            errorMessage = 'Request timed out. Please check your connection and try again.';
          } else if (e.toString().contains('SocketException')) {
            errorMessage = 'Cannot connect to server. Make sure the backend is running on port 3000.';
          } else {
            errorMessage = 'Sorry, I encountered an error: ${e.toString()}';
          }
          
          _messages.add(Message(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
      }
    }
  }
}
