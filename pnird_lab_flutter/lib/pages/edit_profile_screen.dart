import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pnirdlab/services/post_service.dart';
import 'package:pnirdlab/utils/image_processor.dart';



class ProfileEditScreen extends StatefulWidget {
  final String userId;
  const ProfileEditScreen({super.key, required this.userId});
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
 
  final _bio = TextEditingController();
  final _username = TextEditingController();
  String? _errorMessage;
  String? _uploadedImageUrl; // Store the uploaded image URL


Future<void> updateUserProfile(userId, bio, username, profilePicture) async {
  final url = '${ApiService.baseUrl}/users/${widget.userId}';

  // Only include fields that have values (not empty)
  final Map<String, dynamic> updateData = {
    'userId': widget.userId,
  };

  if (bio != null && bio.isNotEmpty) {
    updateData['bio'] = bio;
  }
  
  if (username != null && username.isNotEmpty) {
    updateData['username'] = username;
  }
  
  if (profilePicture != null && profilePicture.isNotEmpty) {
    updateData['profilePicture'] = profilePicture;
  }

  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updateData),
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
      const SnackBar(
        content: Text('Your information has been updated.Please reload the app to see your changes!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
      );

      if (result == null || result.files.isEmpty) return; // No file selected
      
      final filePath = result.files.first.path!;
      final originalFile = File(filePath);
      
      // Validate image
      final isValid = await ImageProcessor.validateImage(originalFile);
      if (!isValid) {
        setState(() {
          _errorMessage = 'Invalid image. Please select a JPG, PNG, or WebP image under 2MB.';
        });
        return;
      }

      // Clear error message after successful validation
      setState(() {
        _errorMessage = null;
      });

      // Process image (resize, compress, convert to JPEG)
      final processedFile = await ImageProcessor.processPostImage(originalFile);
      if (processedFile == null) {
        setState(() {
          _errorMessage = 'Failed to process image. Please try again.';
        });
        return;
      }

      final fileBytes = await processedFile.readAsBytes();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                    ? const Icon(Icons.camera_alt, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImageAndUpload,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add a photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            
       
            const SizedBox(height: 20),
            TextFormField(
              controller: _username,
              decoration: InputDecoration(
                labelText: 'Edit username',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _bio,
              decoration: InputDecoration(
                labelText: 'Edit bio',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description, color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                String bio = _bio.text;
String username = _username.text;
                updateUserProfile(widget.userId, bio, username, _uploadedImageUrl?? '');

              },
              style: ElevatedButton.styleFrom(
           
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 60),
              ),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
