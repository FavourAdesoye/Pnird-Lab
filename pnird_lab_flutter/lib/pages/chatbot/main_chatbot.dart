import 'dart:convert';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/pages/about_us.dart';
import 'package:pnirdlab/pages/chatbot/consts.dart';

class Chathome extends StatelessWidget {
  

  const Chathome({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ChatPage());
  }
}
class ChatPage extends StatefulWidget { 
  const ChatPage({super.key}); 

  @override State<ChatPage> createState() => _ChatPageState();
} 

class _ChatPageState extends State<ChatPage> {   

  //calling openai chatgpt
  final _openAI = OpenAI.instance.build(token: openApiKey, baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5,)), enableLog:true); 
  

  //saves messages for current user
  final ChatUser  _currentUser = ChatUser(id: '1', firstName: "Billy", lastName: "Smith"); 

  //saves messages for chatgpt
  final ChatUser  _gptChatUser = ChatUser(id: '2', firstName: "Chat", lastName: "GPT"); 

  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<ChatUser> _typingUsers = <ChatUser>[];
  @override
  Widget build(BuildContext context){ 
    return Scaffold(
     appBar: AppBar( 
        backgroundColor: Colors.black,
        title: const Center(child: Text('Learn more about the Lab', style: TextStyle(color: Colors.white))),  
         leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
             Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage())
                );
          },
        ),
      ), 
      //displays messages between gpt and user
      body: DashChat(currentUser: _currentUser, typingUsers: _typingUsers, messageOptions:const MessageOptions(currentUserContainerColor: Colors.black, currentUserTextColor: Colors.white, containerColor: Colors.yellow, textColor: Colors.black) ,onSend: (ChatMessage m) { 
        getChatResponse(m);
      }, messages:  _messages),
    );
  } 

  //displays current user message on screen, stores messages history, calls gpt and retrieves response
  Future<void> getChatResponse(ChatMessage m) async { 
    setState(() { 
      _messages.insert(0,m); 
      _typingUsers.add(_gptChatUser);
    });  

    try { 
      final reply = await getAssistantResponse(m.text); 
      setState(() { 
        _messages.insert( 
          0, 
          ChatMessage(user: _gptChatUser, createdAt: DateTime.now(), text: reply),
        );
      });
    } catch (e) { 
      setState(() { 
        _messages.insert( 
          0, 
          ChatMessage(user: _gptChatUser, createdAt: DateTime.now(), text: 'Error: $e'),
        );
      });
    }
    setState(() { 
      _typingUsers.remove(_gptChatUser);
    });
  } 

  Future<String> getAssistantResponse(String userMessage) async { 
    const String apiKey = openApiKey; 
    const String assistant = assistantId; 
    final headers = { 
      'Authorization': 'Bearer $apiKey', 
      'Content-Type': 'application/json', 
      'OpenAI-Beta' : 'assistants=v1',
    };  

    // Step 1: Create a new thread
    final threadResponse = await http.post(
      Uri.parse('https://api.openai.com/v1/threads'),
      headers: headers,
    );
    final threadId = jsonDecode(threadResponse.body)['id'];

    // Step 2: Send the user's message to the thread
    await http.post(
      Uri.parse('https://api.openai.com/v1/threads/$threadId/messages'),
      headers: headers,
      body: jsonEncode({
        'role': 'user',
        'content': userMessage,
      }),
    );

    // Step 3: Run the assistant
    final runResponse = await http.post(
      Uri.parse('https://api.openai.com/v1/threads/$threadId/runs'),
      headers: headers,
      body: jsonEncode({'assistant_id': assistant}),
    );
    final runId = jsonDecode(runResponse.body)['id'];

    // Step 4: Poll for completion
    String status = 'queued';
    while (status != 'completed') {
      final statusResponse = await http.get(
        Uri.parse('https://api.openai.com/v1/threads/$threadId/runs/$runId'),
        headers: headers,
      );
      final statusJson = jsonDecode(statusResponse.body);
      status = statusJson['status'];
      if (status != 'completed') {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // Step 5: Fetch assistant's reply
    final messagesResponse = await http.get(
      Uri.parse('https://api.openai.com/v1/threads/$threadId/messages'),
      headers: headers,
    );
    final messages = jsonDecode(messagesResponse.body)['data'];
    final lastMessage = messages.firstWhere((m) => m['role'] == 'assistant');

    return lastMessage['content'][0]['text']['value'];
  }
}
