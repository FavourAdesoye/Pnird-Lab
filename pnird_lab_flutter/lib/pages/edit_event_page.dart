import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/services/session_storage.dart';
import 'package:pnirdlab/widgets/optimized_image.dart';

class EditEventPage extends StatefulWidget {
  final Map<String, dynamic> event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _locationController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _imageUrl;
  String? _errorMessage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event['titlepost']?.toString() ?? '');
    _descriptionController = TextEditingController(text: event['description']?.toString() ?? '');
    _locationController = TextEditingController(text: event['location']?.toString() ?? '');
    _imageUrl = event['image_url']?.toString();

    final rawDate = event['dateofevent']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        _selectedDate = parsed.toLocal();
      }
    }
    _dateController = TextEditingController(
      text: _selectedDate == null ? '' : DateFormat('yyyy-MM-dd').format(_selectedDate!),
    );

    final rawTime = (event['timeofevent'] ?? event['timeofEvent'])?.toString() ?? '';
    _timeController = TextEditingController(text: rawTime);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final minute = picked.minute.toString().padLeft(2, '0');
    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    setState(() {
      _selectedTime = picked;
      _timeController.text = '$hour:$minute $period';
    });
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
    } catch (_) {
      setState(() => _errorMessage = 'Could not upload the image.');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      setState(() => _errorMessage = 'An image is required.');
      return;
    }
    if (!await SessionStorage.isStaff()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only staff can edit events.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final id = widget.event['_id']?.toString() ?? '';
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/events/event/$id'),
        headers: await ApiService.authHeaders(),
        body: jsonEncode({
          'titlepost': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'image_url': _imageUrl,
          'dateofevent': _dateController.text.trim(),
          'timeofevent': _timeController.text.trim(),
          'location': _locationController.text.trim(),
        }),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updated = data is Map
            ? Map<String, dynamic>.from(data)
            : Map<String, dynamic>.from(widget.event);
        Navigator.pop(context, updated);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 403
                ? 'Only staff can edit events.'
                : 'Could not save the event (${response.statusCode}).',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the event. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit event')),
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
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: _saving ? null : _selectDate,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please select a date' : null,
              ),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Time'),
                onTap: _saving ? null : _selectTime,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please select a time' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter a location' : null,
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
