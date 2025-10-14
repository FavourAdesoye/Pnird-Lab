import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/pages/about_us.dart';

class Chathome extends StatelessWidget {
  const Chathome({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Current user (you)
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: "Billy", lastName: "Smith");

  // Bot user
  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: "Chat", lastName: "Bot");

  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<ChatUser> _typingUsers = <ChatUser>[];

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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
          },
        ),
      ),
      body: DashChat(
        currentUser: _currentUser,
        typingUsers: _typingUsers,
        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.black,
          currentUserTextColor: Colors.white,
          containerColor: Colors.yellow,
          textColor: Colors.black,
        ),
        onSend: (ChatMessage m) {
          getChatResponse(m);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _typingUsers.add(_gptChatUser);
    });

    try {
      final reply = await getAssistantResponse(m.text);
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
              user: _gptChatUser, createdAt: DateTime.now(), text: reply),
        );
      });
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
              user: _gptChatUser,
              createdAt: DateTime.now(),
              text: 'Error: $e'),
        );
      });
    }
    setState(() {
      _typingUsers.remove(_gptChatUser);
    });
  }

  // ✅ Updated: Call your Node.js backend instead of OpenAI
  Future<String> getAssistantResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:3000/ask"), // Replace with your backend URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["answer"];
      } else {
        return "Error: ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
