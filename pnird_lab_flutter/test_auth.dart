import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthTestPage extends StatefulWidget {
  @override
  _AuthTestPageState createState() => _AuthTestPageState();
}

class _AuthTestPageState extends State<AuthTestPage> {
  String _status = 'Ready to test';
  bool _isLoading = false;

  Future<void> testRegistration() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing registration...';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/register'),
        body: {
          'username': 'Test User',
          'email': 'test@example.com',
          'password': 'password123',
          'role': 'student',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = '✅ Registration successful!\n${response.body}';
        });
      } else {
        setState(() {
          _status = '❌ Registration failed: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Registration error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> testLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing login...';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/login'),
        body: {'email': 'test@example.com'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = '✅ Login successful!\n${response.body}';
        });
      } else {
        setState(() {
          _status = '❌ Login failed: ${response.statusCode}\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Login error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Test'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Authentication Test',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : testRegistration,
              child: Text('Test Registration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _isLoading ? null : testLogin,
              child: Text('Test Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Auth Test',
    theme: ThemeData.dark(),
    home: AuthTestPage(),
  ));
}
