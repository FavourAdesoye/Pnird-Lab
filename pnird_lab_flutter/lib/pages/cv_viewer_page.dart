import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Check if it's a local asset path
      if (widget.cvPath.startsWith('assets/')) {
        await _loadAssetPdf();
      } else if (widget.cvPath.startsWith('http')) {
        await _loadNetworkPdf();
      } else {
        // Assume it's a local file path
        localPath = widget.cvPath;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load CV: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadAssetPdf() async {
    try {
      // For asset PDFs, we need to copy them to local storage
      final bytes = await DefaultAssetBundle.of(context).load(widget.cvPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.cvPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      
      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load asset PDF: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadNetworkPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.cvPath));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = widget.cvPath.split('/').last;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to download CV from network';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load network PDF: $e';
        isLoading = false;
      });
    }
  }

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
          if (isReady && totalPages > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '$currentPage / $totalPages',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
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
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.yellow),
            SizedBox(height: 20),
            Text(
              'Loading CV...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.withOpacity(0.7),
              ),
              const SizedBox(height: 20),
              Text(
                'Error Loading CV',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _loadPdf(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (localPath == null) {
      return Center(
        child: Padding(
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
                'CV Not Available',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'CV for ${widget.memberName} is not available for viewing.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Check file extension to determine viewer type
    final fileExtension = localPath!.toLowerCase().split('.').last;
    
    if (fileExtension == 'pdf') {
      return PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        pageSnap: true,
        onRender: (pages) {
          setState(() {
            totalPages = pages!;
            isReady = true;
          });
        },
        onViewCreated: (PDFViewController pdfViewController) {
          // Controller is available if needed for future enhancements
        },
        onPageChanged: (page, total) {
          setState(() {
            currentPage = page! + 1;
          });
        },
        onError: (error) {
          setState(() {
            errorMessage = 'Error displaying PDF: $error';
          });
        },
      );
    } else if (fileExtension == 'docx') {
      return Center(
        child: Padding(
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
                'DOCX File',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This CV is in DOCX format. To view the full document, please download it or contact ${widget.memberName} directly.',
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
                label: const Text('Download CV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
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
                'Unsupported File Type',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'File type .$fileExtension is not supported for viewing.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
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
