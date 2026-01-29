import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  _ApiTestPageState createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _testResults = '';
  bool _isLoading = false;

  Future<void> _testApiConnection() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing API connection...\n';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseId = prefs.getString('firebaseId') ?? '';
      final mongoUserId = prefs.getString('userId') ?? '';

      _testResults += 'Firebase ID: $firebaseId\n';
      _testResults += 'MongoDB User ID: $mongoUserId\n\n';

      // Test different API URLs
      final urls = [
        '${ApiService.baseUrl}/messages/chats/$firebaseId',
      ];

      for (String url in urls) {
        _testResults += 'Testing URL: $url\n';
        
        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          _testResults += 'Status: ${response.statusCode}\n';
          _testResults += 'Response: ${response.body}\n\n';

          if (response.statusCode == 200) {
            _testResults += '✅ SUCCESS! This URL works.\n\n';
            break;
          }
        } catch (e) {
          _testResults += '❌ Error: $e\n\n';
        }
      }

      // Test backend health
      _testResults += 'Testing backend health...\n';
      try {
        final healthResponse = await http.get(
          Uri.parse('http://10.0.2.2:3000/api/health'),
        ).timeout(const Duration(seconds: 5));
        
        _testResults += 'Health check status: ${healthResponse.statusCode}\n';
        _testResults += 'Health response: ${healthResponse.body}\n';
      } catch (e) {
        _testResults += 'Health check failed: $e\n';
      }

    } catch (e) {
      _testResults += 'Test failed: $e\n';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text(
          'API Test',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testApiConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Test API Connection'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults.isEmpty ? 'Click "Test API Connection" to start debugging' : _testResults,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


