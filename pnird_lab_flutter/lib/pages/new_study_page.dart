import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; // For selecting images
import '../model/study_model.dart';
import '../services/studies_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/file_utils.dart';
import 'studies.dart';

class NewStudyPage extends StatefulWidget {
  const NewStudyPage({super.key});

  @override
  _NewStudyPageState createState() => _NewStudyPageState();
}

class _NewStudyPageState extends State<NewStudyPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String? _uploadedImageUrl; // Store the uploaded image URL
  String? _errorMessage;
  File? _selectedFile;
  bool _allowScheduling = false;
  bool _allowComments = false;

  // Pick image method
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

  Future<void> _submitStudy() async {
    try {
      if (_formKey.currentState!.validate()) {
        // Save the form fields
        _formKey.currentState!.save();
        if (_uploadedImageUrl == null || _uploadedImageUrl!.isEmpty) {
          throw Exception("Image URL is required.");
        }

        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/api/studies/createstudy'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'titlepost': _title,
            'description': _description,
            'image_url': _uploadedImageUrl, // Cloudinary URL
            'allowScheduling': _allowScheduling,
            'allowComments': _allowComments
          }),
        );
        print("Title: $_title, Description: $_description");

        final newStudy = Study.fromJson(jsonDecode(response.body));
        Navigator.pop(context, newStudy); // Return the new study to StudiesPage
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Study')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => _title = value!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value!,
                ),
                SizedBox(height: 20),
                if (kIsWeb)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Image URL'),
                    onChanged: (value) => _uploadedImageUrl = value,
                  )
                else
                  ElevatedButton(
                    onPressed: _pickImageAndUpload,
                    child: Text('Select Image File'),
                  ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (_uploadedImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Text('Uploaded Image:'),
                        SizedBox(height: 10),
                        Image.network(_uploadedImageUrl!, height: 150),
                      ],
                    ),
                  ),
                SwitchListTile(
                  title: Text('Allow Scheduling'),
                  value: _allowScheduling,
                  onChanged: (value) {
                    setState(() {
                      _allowScheduling = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Allow Comments'),
                  value: _allowComments,
                  onChanged: (value) {
                    setState(() {
                      _allowComments = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitStudy,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
