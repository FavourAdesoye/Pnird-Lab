import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/services/chatbot_service.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  static final Uri _policyUrl = Uri.parse('https://pnirdlab.com/privacy');
  bool _deleting = false;
  String? _chatbotNotice;
  bool _loadingNotice = true;

  @override
  void initState() {
    super.initState();
    _loadChatbotNotice();
  }

  Future<void> _loadChatbotNotice() async {
    try {
      final config = await ChatbotService.getPrivacyConfig();
      if (!mounted) return;
      setState(() {
        _chatbotNotice = ChatbotService.privacyNoticeText(config);
        _loadingNotice = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _chatbotNotice = ChatbotService.privacyNoticeText(const {
          'saveConversations': true,
          'retentionDays': 30,
          'maxMessages': 40,
        });
        _loadingNotice = false;
      });
    }
  }

  Future<void> _openPolicy() async {
    final opened = await launchUrl(_policyUrl, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the privacy policy link.')),
      );
    }
  }

  Future<void> _deleteMyData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your app data?'),
        content: const Text(
          'This permanently deletes your messages, notifications, and chatbot history from PNIRD Lab servers. Your account login is not removed — contact support for full account deletion.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deleting = true);
    try {
      final response = await http.delete(
        Uri.parse(ApiService.deleteMyDataEndpoint),
        headers: await ApiService.authHeaders(),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your stored messages, notifications, and chatbot history were deleted.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete data (${response.statusCode}). Are you logged in?')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete data. Check your connection and try again.')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Your Privacy Matters',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'PNIRD Lab collects only the data needed to provide community features, authentication, messaging, and notifications.',
          ),
          const SizedBox(height: 12),
          const Text('We may process:'),
          const SizedBox(height: 8),
          const Text('- Account information (email, username, profile details)'),
          const Text('- User-generated content (posts, comments, messages)'),
          const Text('- Chatbot questions you send (may be processed by OpenAI)'),
          const Text('- Device and diagnostic data for app reliability'),
          const SizedBox(height: 12),
          Text(
            'Chatbot history',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_loadingNotice)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Text(_chatbotNotice ?? ''),
          const SizedBox(height: 12),
          const Text(
            'Third-party processors may include Firebase (authentication), MongoDB (app data), Cloudinary (images), and OpenAI (chatbot).',
          ),
          const SizedBox(height: 12),
          const Text(
            'You can delete messages, notifications, and chatbot history below. Full account deletion is handled by contacting support.',
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _openPolicy,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Read Full Privacy Policy'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _deleting ? null : _deleteMyData,
            icon: _deleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline),
            label: Text(_deleting ? 'Deleting…' : 'Delete my messages & chat history'),
          ),
        ],
      ),
    );
  }
}
