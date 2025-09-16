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
import 'package:pnirdlab/model/post_model.dart';
import 'package:pnirdlab/utils/image_processor.dart';



class CreatePostScreen extends StatefulWidget {
  final String userId;
  CreatePostScreen({required this.userId});
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
 
  final _description = TextEditingController();
  File? _selectedFile;
  String? _errorMessage;
  String? _uploadedImageUrl; // Store the uploaded image URL

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
        allowedExtensions: ImageProcessor.allowedFormats,
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

      // Process image (resize, compress, convert to JPEG)
      final processedFile = await ImageProcessor.processPostImage(originalFile);
      if (processedFile == null) {
        setState(() {
          _errorMessage = 'Failed to process image. Please try again.';
        });
        return;
      }

      final fileBytes = await processedFile.readAsBytes();
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';

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
  Future<void>_createPost() async{
    print('Creating post button clicked...');
    try{
      if (_description.text.isEmpty || _uploadedImageUrl == null || _uploadedImageUrl!.isEmpty) {
        throw Exception("Description or image is empty");
      }
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/posts/upload'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'description': _description.text,
          'img': _uploadedImageUrl,
          'userId': widget.userId,
        }),
      );
      if(response.statusCode == 200){
        print('Post created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Post created successfully')),
);
        final newPost = Post.fromJson(jsonDecode(response.body));
        Navigator.pop(context, newPost);
      }else{
        print('Failed to create post: ${response.statusCode}');
      }
    }
    catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
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
              controller: _description,
              decoration: InputDecoration(
                labelText: 'Write a caption...',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 40),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _createPost,    
              child: Text('Create Post'),
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
