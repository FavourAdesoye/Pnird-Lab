import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../../widgets/auth_button.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  
  const EmailVerificationPage({super.key, required this.email});

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCount = 0;
  final int _maxResendAttempts = 3;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Wait a moment for user to verify
      await Future.delayed(Duration(seconds: 2));
      
      // Try checking verification status multiple times with delays
      bool isVerified = false;
      for (int attempt = 0; attempt < 3; attempt++) {
        print('Verification check attempt ${attempt + 1}');
        isVerified = await Auth.isEmailVerified();
        
        if (isVerified) {
          print('Email verified on attempt ${attempt + 1}');
          break;
        }
        
        if (attempt < 2) {
          print('Not verified yet, waiting 3 seconds before retry...');
          await Future.delayed(Duration(seconds: 3));
        }
      }
      
      setState(() {
        _isVerified = isVerified;
      });
      
      if (isVerified) {
        // Email is verified, navigate to main screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verified successfully! Welcome!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Email not verified, show message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email not yet verified. Please check your inbox AND spam folder, then click the verification link.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error checking verification status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking verification status. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCount >= _maxResendAttempts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum resend attempts reached. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      final result = await Auth.resendVerificationEmail(widget.email);
      
      if (result.success) {
        setState(() {
          _resendCount++;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email sent! Check your inbox and spam folder.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend verification email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isResending = false;
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
          'Verify Email',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email verification icon
            Icon(
              Icons.mark_email_unread_outlined,
              size: 80,
              color: Colors.yellow,
            ),
            SizedBox(height: 30),
            
            // Title
            Text(
              'Check Your Email',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Description
            Text(
              'We\'ve sent a verification link to:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            
            // Email address
            Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.withOpacity(0.3)),
              ),
              child: Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.yellow,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 15),
            
            // Verification status indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _isVerified ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isVerified ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isVerified ? Icons.check_circle : Icons.schedule,
                    color: _isVerified ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _isVerified ? 'Email Verified!' : 'Pending Verification',
                    style: TextStyle(
                      fontSize: 14,
                      color: _isVerified ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Important: Check Your Spam Folder!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Verification emails often end up in spam/junk folders. Please check your spam folder if you don\'t see the email in your inbox.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[300],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Click the verification link in your email to activate your account, then return to the app.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[300],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            
            // Resend button
            AuthButton(
              text: _isResending ? 'Sending...' : 'Resend Verification Email',
              onPressed: _isResending ? null : _resendVerificationEmail,
              isLoading: _isResending,
            ),
            SizedBox(height: 20),
            
            // Check verification button
            AuthButton(
              text: _isLoading ? 'Checking...' : 'Check Verification Status',
              onPressed: _isLoading ? null : _checkVerificationStatus,
              isLoading: _isLoading,
              backgroundColor: Colors.transparent,
              textColor: Colors.white,
            ),
            SizedBox(height: 10),
            
            // Manual refresh button
            TextButton.icon(
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                });
                await _checkVerificationStatus();
              },
              icon: Icon(Icons.refresh, color: Colors.blue, size: 16),
              label: Text(
                'Refresh Status',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
            SizedBox(height: 20),
            
            // Resend attempts info
            if (_resendCount > 0)
              Text(
                'Resend attempts: $_resendCount/$_maxResendAttempts',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            
            SizedBox(height: 20),
            
            // Additional help tip
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Pro Tip:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add noreply@pnird-lab.firebaseapp.com to your contacts or whitelist to prevent future emails from going to spam.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 15),
            
            // Debug info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.bug_report, color: Colors.grey[400], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Troubleshooting:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'If you\'ve verified your email but it still shows as unverified, try:\n1. Wait 1-2 minutes for Firebase to update\n2. Use the "Refresh Status" button above\n3. Close and reopen the app\n4. Check the console logs for debugging info',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
