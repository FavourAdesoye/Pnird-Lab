import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pnirdlab/model/study_model.dart';
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/services/session_storage.dart';
import 'package:pnirdlab/widgets/optimized_image.dart';

class EditStudyPage extends StatefulWidget {
  final Study study;

  const EditStudyPage({super.key, required this.study});

  @override
  State<EditStudyPage> createState() => _EditStudyPageState();
}

class _EditStudyPageState extends State<EditStudyPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _formLinkController;
  String? _imageUrl;
  String? _errorMessage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.study.titlePost);
    _descriptionController = TextEditingController(text: widget.study.description);
    _formLinkController = TextEditingController(text: widget.study.formLink ?? '');
    _imageUrl = widget.study.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _formLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndUpload() async {
    try {
      final uploadUrl = dotenv.env['CLOUDINARY_UPLOAD_URL'];
      final uploadPreset = dotenv.env['UPLOAD_PRESET'];
      final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
      if (uploadUrl == null || uploadPreset == null || apiKey == null) {
        setState(() => _errorMessage = 'Image upload is not configured.');
        return;
      }

      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.isEmpty) return;

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.fields['api_key'] = apiKey;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        result.files.first.bytes!,
        filename: result.files.first.name,
      ));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        setState(() {
          _imageUrl = data['secure_url']?.toString();
          _errorMessage = null;
        });
      } else {
        setState(() => _errorMessage = 'Image upload failed (${response.statusCode}).');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not upload the image.');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await SessionStorage.isStaff()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only staff can edit studies.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/studies/${widget.study.id}'),
        headers: await ApiService.authHeaders(),
        body: jsonEncode({
          'titlepost': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'image_url': _imageUrl ?? '',
          'formLink': _formLinkController.text.trim(),
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updated = data is Map && data['study'] is Map
            ? Study.fromJson(Map<String, dynamic>.from(data['study'] as Map))
            : Study(
                id: widget.study.id,
                imageUrl: _imageUrl ?? '',
                description: _descriptionController.text.trim(),
                titlePost: _titleController.text.trim(),
                createdAt: widget.study.createdAt,
                updatedAt: DateTime.now(),
                formLink: _formLinkController.text.trim(),
              );
        Navigator.pop(context, updated);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 403
                ? 'Only staff can edit studies.'
                : 'Could not save the study (${response.statusCode}).',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the study. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit study')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: 16),
              if (_imageUrl != null && _imageUrl!.isNotEmpty)
                OptimizedImage(
                  imageUrl: _imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _saving ? null : _pickImageAndUpload,
                child: const Text('Replace image'),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _formLinkController,
                decoration: const InputDecoration(
                  labelText: 'Form link (optional)',
                  hintText: 'Google Forms or Microsoft Forms URL',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
