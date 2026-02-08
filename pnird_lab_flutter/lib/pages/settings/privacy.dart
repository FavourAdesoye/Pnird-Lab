import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static final Uri _policyUrl = Uri.parse('https://pnirdlab.com/privacy');

  Future<void> _openPolicy(BuildContext context) async {
    final opened = await launchUrl(_policyUrl, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the privacy policy link.')),
      );
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
          const Text('- Device and diagnostic data for app reliability'),
          const SizedBox(height: 12),
          const Text(
            'You can request account/data deletion by contacting support.',
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openPolicy(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Read Full Privacy Policy'),
          ),
        ],
      ),
    );
  }
}
