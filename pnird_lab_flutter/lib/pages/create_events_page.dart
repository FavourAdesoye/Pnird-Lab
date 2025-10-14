import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pnirdlab/pages/events_page.dart';


class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _dateOfEvent = '';
  String _timeOfEvent = '';
  String _month = '';
  String _location = '';
  String? _uploadedImageUrl;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _pickImageAndUpload() async {
    setState(() => _isLoading = true);

    try {
      final uploadUrl = dotenv.env['CLOUDINARY_UPLOAD_URL'];
      final uploadPreset = dotenv.env['UPLOAD_PRESET'];
      final apiKey = dotenv.env['CLOUDINARY_API_KEY'];

      if (uploadUrl == null || uploadPreset == null || apiKey == null) {
        setState(() {
          _errorMessage = 'Missing Cloudinary config.';
          _isLoading = false;
        });
        return;
      }

      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final fileBytes = result.files.first.bytes!;
      final fileName = result.files.first.name;

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['api_key'] = apiKey;
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        setState(() {
          _uploadedImageUrl = responseData['secure_url'];
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Image upload failed (${response.statusCode})');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedImageUrl == null || _uploadedImageUrl!.isEmpty) {
      setState(() => _errorMessage = 'Image is required.');
      return;
    }

    setState(() => _isLoading = true);

    _formKey.currentState!.save();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/events/createevent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titlepost': _title,
          'description': _description,
          'image_url': _uploadedImageUrl,
          'dateofevent': _dateOfEvent,
          'timeofevent': _timeOfEvent,
          'month': _month,
          'location': _location,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventsPage()), // <-- Navigate to events page
        );
      } else {
        throw Exception('Server error ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Event')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter title' : null,
                        onSaved: (value) => _title = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Description'),
                        onSaved: (value) => _description = value!,
                      ),
                      TextFormField( //Future improvement: Use a date picker
                        decoration: const InputDecoration(labelText: 'Date (e.g. 2024-04-01)'),
                        onSaved: (value) => _dateOfEvent = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Time (e.g. 4:00 PM)'),
                        onSaved: (value) => _timeOfEvent = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Month'),
                        onSaved: (value) => _month = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Location'),
                        onSaved: (value) => _location = value!,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _pickImageAndUpload,
                        child: const Text('Upload Event Image'),
                      ),
                      if (_uploadedImageUrl != null) ...[
                        const SizedBox(height: 10),
                        Image.network(_uploadedImageUrl!, height: 150),
                      ],
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitEvent,
                        child: const Text('Submit Event'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
