import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/services/chatbot_service.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class _ChatPageState extends State<Chathome> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _isLoading = false;
  String? _userId;
  String? _currentConversationId;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoadingConversations = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadUserId();
    await _loadConversations();
    // Auto-load the most recent conversation if available
    if (_conversations.isNotEmpty && _userId != null) {
      _loadConversation(_conversations[0]['_id']);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    print('🔍 Loaded userId: $userId');
    setState(() {
      _userId = userId;
    });
    
    if (userId == null) {
      print('⚠️  Warning: userId is null, conversations will not be saved');
    }
  }

  Future<void> _loadConversations() async {
    if (_userId == null) {
      print('⚠️ Cannot load conversations: userId is null');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingConversations = true;
      });
    }

    try {
      final conversations = await ChatbotService.getConversations(_userId!);
      print('✅ Loaded ${conversations.length} conversations');
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoadingConversations = false;
        });
      }
    } catch (e) {
      print('❌ Error loading conversations: $e');
      if (mounted) {
        setState(() {
          _isLoadingConversations = false;
        });
      }
    }
  }

  Future<void> _loadConversation(String conversationId) async {
    if (_userId == null) return;

    try {
      final conversation = await ChatbotService.getConversation(_userId!, conversationId);
      if (mounted) {
        setState(() {
          _currentConversationId = conversationId;
          _messages.clear();
          _messages.addAll(
            (conversation['messages'] as List)
                .map((msg) => Message.fromJson(msg))
                .toList(),
          );
        });
        _scrollToBottom();
        if (_scaffoldKey.currentState?.isDrawerOpen == true) {
          _scaffoldKey.currentState?.closeDrawer();
        }
      }
    } catch (e) {
      print('Error loading conversation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load conversation: $e')),
        );
      }
    }
  }

  Future<void> _startNewConversation() async {
    setState(() {
      _currentConversationId = null;
      _messages.clear();
    });
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _deleteConversation(String conversationId) async {
    if (_userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ChatbotService.deleteConversation(_userId!, conversationId);
        if (_currentConversationId == conversationId) {
          _startNewConversation();
        }
        _loadConversations();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete conversation: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: const Text('Chat with AI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ask me anything about the lab!',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'I can answer questions using lab documents',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
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

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _startNewConversation,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'New Conversation',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoadingConversations
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                    ? Center(
                        child: Text(
                          'No conversations yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          final conv = _conversations[index];
                          final isSelected = conv['_id'] == _currentConversationId;
                          return ListTile(
                            selected: isSelected,
                            title: Text(
                              conv['title'] ?? 'Untitled',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${conv['messageCount']} messages',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteConversation(conv['_id']),
                            ),
                            onTap: () => _loadConversation(conv['_id']),
                          );
                        },
                      ),
          ),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
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
      // Build conversation history (all messages except the one we're about to send)
      // The user message was already added to _messages in _sendMessage()
      final conversationHistory = _messages
          .where((msg) => msg != _messages.last) // Exclude the last message (the one we just added)
          .map((msg) => msg.toJson())
          .toList();
      
      print('📝 Conversation history length: ${conversationHistory.length}, Total messages: ${_messages.length}');

      print('📤 Sending message with userId: $_userId, conversationId: $_currentConversationId');
      
      final response = await ChatbotService.sendMessage(
        message: userMessage,
        conversationHistory: conversationHistory,
        userId: _userId,
        conversationId: _currentConversationId,
      );
      
      print('📥 Received response, conversationId: ${response['conversationId']}');

      final botMessage = response['answer'] ?? 'Sorry, I could not process your request.';
      final conversationId = response['conversationId'];

      if (mounted) {
        setState(() {
          _messages.add(Message(
            text: botMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
          if (conversationId != null) {
            _currentConversationId = conversationId;
          }
        });
        _scrollToBottom();
        
        // Refresh conversations list to show updated conversation
        if (conversationId != null) {
          await _loadConversations();
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
            errorMessage = 'Cannot connect to server. Please check your connection.';
          } else {
            errorMessage = 'Sorry, I encountered an error. Please try again.';
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
