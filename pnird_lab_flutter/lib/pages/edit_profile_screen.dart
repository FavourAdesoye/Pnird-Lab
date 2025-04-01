import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:pnirdlab/services/user_service.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pnirdlab/services/post_service.dart';



class ProfileEditScreen extends StatefulWidget {
  final String userId;
  ProfileEditScreen({required this.userId});
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
 
  final _bio = TextEditingController();
  final _username = TextEditingController();
  File? _selectedFile;
  String? _errorMessage;
  String? _uploadedImageUrl; // Store the uploaded image URL


Future<void> updateUserProfile(userId, bio, username, profilePicture) async {
  final url = 'http://localhost:3000/api/users/${widget.userId}';  // Replace with your backend URL

  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer your-token-here',  // If you use authentication tokens
    },
    body: jsonEncode({
      'userId': widget.userId,
      'bio': bio,
      'username': username,
      'profilePicture': profilePicture,  // Include photo URL if available
    }),
  );

  if (response.statusCode == 200) {
      // Handle success - Show success message
      final updatedUser = jsonDecode(response.body);
      print('User updated successfully: $updatedUser');
      
      // Show a SnackBar to notify the user
      _showSuccessMessage();
      getPosts();
      
    } else {
      // Handle error - Show error message
      print('Error updating user: ${response.body}');
      _showErrorMessage();
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your information has been updated.Please reload the app to see your changes!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update your information. Please try again.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _pickImageAndUpload() async {
    try {
      final uploadUrl = dotenv.env['CLOUDINARY_UPLOAD_URL'];
      final uploadPreset = dotenv.env['UPLOAD_PRESET'];
      final apiKey = dotenv.env['CLOUDINARY_API_KEY'];

      if (uploadUrl == null || uploadPreset == null || apiKey == null) {
        setState(() {
          _errorMessage = 'Environment variables not configured.';
        });
        return;
      }

      // Pick the file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // Ensures we get the file bytes
      );

      if (result == null || result.files.isEmpty) return; // No file selected
      final fileBytes = result.files.first.bytes!;
      final fileName = result.files.first.name;

      // Create a multipart request for the file
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['api_key'] = apiKey;

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        setState(() {
          _uploadedImageUrl =
              responseData['secure_url']; // Extract the secure URL
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to upload image. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  Future<void> _pickFileForMobile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: false,
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        final filePath = result.files.single.path!;

        // Validate file type before using it
        checkFileType(filePath); // Check file type here

        setState(() {
          _selectedFile = File(filePath);
        });
        print('File selected: $filePath');
      } else {
        throw Exception('No file selected or path is unavailable.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImageAndUpload,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _uploadedImageUrl == null ? null : Image.network(_uploadedImageUrl!, fit: BoxFit.cover).image,
                child: _uploadedImageUrl == null
                    ? Icon(Icons.camera_alt, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _pickImageAndUpload,
              child: Text('Add a photo', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              ),
            ),
            
       
            SizedBox(height: 20),
            TextFormField(
              controller: _username,
              decoration: InputDecoration(
                labelText: 'Edit username',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: _bio,
              decoration: InputDecoration(
                labelText: 'Edit bio',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email, color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                String bio = _bio.text;
String username = _username.text;
                updateUserProfile(widget.userId, bio, username, _uploadedImageUrl?? '');

              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
           
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 60),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
