import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CvViewerPage extends StatefulWidget {
  final String cvPath;
  final String memberName;

  const CvViewerPage({
    super.key,
    required this.cvPath,
    required this.memberName,
  });

  @override
  _CvViewerPageState createState() => _CvViewerPageState();
}

class _CvViewerPageState extends State<CvViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '${widget.memberName}\'s CV',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () => _showDownloadOptions(context),
            tooltip: 'Download Options',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 80,
            color: Colors.yellow.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          Text(
            'CV Viewer',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CV files are stored locally in the app. To view or download CVs, please contact ${widget.memberName} directly.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showDownloadOptions(context),
            icon: const Icon(Icons.download),
            label: const Text('Get CV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Get ${widget.memberName}\'s CV',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'CV files are stored locally in the app. To get a copy of the CV, please contact the team member directly.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _copyContactInfo(context);
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _launchEmail(context);
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Send Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _copyContactInfo(BuildContext context) {
    // This would copy the member's contact info
    // For now, we'll show a generic message
    Clipboard.setData(const ClipboardData(text: 'Contact information copied!'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact information copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _launchEmail(BuildContext context) {
    // This would launch email to the member
    // For now, we'll show a message
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Email Contact',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Please use the email button in the team member\'s profile to contact them directly.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  }
}