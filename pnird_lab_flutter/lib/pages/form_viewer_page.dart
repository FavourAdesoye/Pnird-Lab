import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FormViewerPage extends StatefulWidget {
  final String formUrl;
  final String studyTitle;

  const FormViewerPage({
    super.key,
    required this.formUrl,
    required this.studyTitle,
  });

  @override
  State<FormViewerPage> createState() => _FormViewerPageState();
}

class _FormViewerPageState extends State<FormViewerPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading form: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.formUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey - ${widget.studyTitle}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
