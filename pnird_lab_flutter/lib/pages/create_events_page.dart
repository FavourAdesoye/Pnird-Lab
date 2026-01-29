import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/pages/events_page.dart';
import 'package:intl/intl.dart';


class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  String _title = '';
  String _description = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _dateOfEvent = '';
  String _timeOfEvent = '';
  String _location = '';
  String? _uploadedImageUrl;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // Yellow
              onPrimary: Theme.of(context).colorScheme.onPrimary, // Black
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _dateOfEvent = _dateController.text;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // Yellow
              onPrimary: Theme.of(context).colorScheme.onPrimary, // Black
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        // Format time in 12-hour format (e.g., "4:00 PM")
        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        _timeController.text = '$hour:$minute $period';
        _timeOfEvent = _timeController.text;
      });
    }
  }

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
        Uri.parse('${ApiService.baseUrl}/events/createevent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titlepost': _title,
          'description': _description,
          'image_url': _uploadedImageUrl,
          'dateofevent': _dateOfEvent,
          'timeofevent': _timeOfEvent,
          // Month will be auto-derived from dateofevent on the backend
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
                      const SizedBox(height: 8),
                      // Date Picker Field
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          hintText: 'Select event date',
                          suffixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                        ),
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (_selectedDate != null) {
                            _dateOfEvent = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      // Time Picker Field
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Time',
                          hintText: 'Select event time',
                          suffixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                        ),
                        readOnly: true,
                        onTap: _selectTime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          if (_selectedTime != null) {
                            final hour = _selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod;
                            final minute = _selectedTime!.minute.toString().padLeft(2, '0');
                            final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
                            _timeOfEvent = '$hour:$minute $period';
                          }
                        },
                      ),
                      const SizedBox(height: 8),
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
