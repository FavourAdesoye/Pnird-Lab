import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EmailTestPage extends StatefulWidget {
  const EmailTestPage({super.key});

  @override
  _EmailTestPageState createState() => _EmailTestPageState();
}

class _EmailTestPageState extends State<EmailTestPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _status = '';

  Future<void> _testEmailVerification() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing email verification...';
    });

    try {
      // Create a test user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      // Send verification email
      await userCredential.user!.sendEmailVerification();
      
      setState(() {
        _status = '✅ Verification email sent successfully!\nCheck your inbox: ${_emailController.text}';
      });

      // Clean up - delete the test user
      await userCredential.user!.delete();
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        _status = '❌ Firebase Error: ${e.code}\n${e.message}';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Email Test', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Email Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Test Email',
                hintText: 'test@example.com',
                labelStyle: TextStyle(color: Colors.yellow),
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Test Password',
                hintText: 'password123',
                labelStyle: TextStyle(color: Colors.yellow),
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
              obscureText: true,
            ),
            SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testEmailVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.black)
                  : Text(
                      'Test Email Verification',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SizedBox(height: 30),
            
            if (_status.isNotEmpty)
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _status.contains('✅') ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _status,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            
            SizedBox(height: 20),
            
            Text(
              'Note: This will create a temporary test account and send a verification email. The test account will be deleted after the test.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

