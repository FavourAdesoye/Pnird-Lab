import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/services/session_storage.dart';
import 'package:pnirdlab/widgets/optimized_image.dart';
import 'edit_event_page.dart';

class EventDetailPage extends StatefulWidget {
  final dynamic event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _isStaff = false;
  bool _deleting = false;
  bool _changed = false;
  late Map<String, dynamic> _event;

  @override
  void initState() {
    super.initState();
    _event = Map<String, dynamic>.from(widget.event as Map);
    _loadRole();
  }

  Future<void> _loadRole() async {
    final staff = await SessionStorage.isStaff();
    if (!mounted) return;
    setState(() => _isStaff = staff);
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This permanently removes the event. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!await SessionStorage.isStaff()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only staff can delete events.')),
      );
      return;
    }

    final id = _event['_id']?.toString() ?? '';
    if (id.isEmpty) return;

    setState(() => _deleting = true);
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/events/event/$id'),
        headers: await ApiService.authHeaders(),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 403
                ? 'Only staff can delete events.'
                : 'Could not delete event (${response.statusCode}).',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete event. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _editEvent() async {
    if (!await SessionStorage.isStaff()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only staff can edit events.')),
      );
      return;
    }
    if (!mounted) return;
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => EditEventPage(event: _event)),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _event = updated;
      _changed = true;
    });
  }

  String formattedDateTime(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _getEventTime() {
    // Check both possible field names (for backward compatibility)
    final time = _event['timeofevent'] ?? _event['timeofEvent'];
    
    if (time != null && time.toString().trim().isNotEmpty) {
      final timeStr = time.toString().trim();
      // Don't show default values as time
      if (timeStr != 'TBD' && 
          timeStr != 'No time specified' && 
          timeStr != 'null' &&
          timeStr.isNotEmpty) {
        return timeStr;
      }
    }
    return 'TBD';
  }

  DateTime? _parseEventDateTime() {
    try {
      // Parse the date
      final eventDate = DateTime.parse(_event['dateofevent']).toLocal();
      
      // Parse the time if available (check both field names for backward compatibility)
      final timeString = _event['timeofevent'] ?? _event['timeofEvent'];
      if (timeString != null && timeString.isNotEmpty && timeString != 'TBD') {
        // Parse time in format "4:00 PM" or "4:00PM"
        final timeFormat = DateFormat('h:mm a');
        try {
          final time = timeFormat.parse(timeString.trim());
          // Combine date and time
          return DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            time.hour,
            time.minute,
          );
        } catch (e) {
          // If time parsing fails, use date only at 9 AM
          return DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            9,
            0,
          );
        }
      } else {
        // No time specified, default to 9 AM
        return DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          9,
          0,
        );
      }
    } catch (e) {
      print('Error parsing event date/time: $e');
      return null;
    }
  }

  Future<void> _addToCalendar() async {
    final startDate = _parseEventDateTime();
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to parse event date/time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // End time is 1 hour after start time (or adjust as needed)
    final endDate = startDate.add(const Duration(hours: 1));

    final event = Event(
      title: _event['titlepost'] ?? 'Event',
      description: _event['description'] ?? '',
      location: _event['location'] ?? '',
      startDate: startDate,
      endDate: endDate,
      iosParams: const IOSParams(
        reminder: Duration(minutes: 15), // Reminder 15 minutes before
      ),
      androidParams: const AndroidParams(
        emailInvites: [],
      ),
    );

    try {
      await Add2Calendar.addEvent2Cal(event);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Event added to calendar!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to calendar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _changed),
        ),
        title: Text(
          () {
            final raw = _event['titlepost']?.toString().trim() ?? '';
            return raw.isEmpty ? 'Event' : raw.capitalize();
          }(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OptimizedImage(
              imageUrl: _event['image_url']?.toString() ?? '',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              _event['description'] ?? 'No description available.',
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Event Date: ${formattedDateTime(DateTime.parse(_event["dateofevent"]).toLocal())}",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Event Time: ${_getEventTime()}",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_event['location'] != null && _event['location'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "Location: ${_event['location']}",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Add to Calendar Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addToCalendar,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Add to Calendar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_isStaff) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleting ? null : _editEvent,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit event'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleting ? null : _deleteEvent,
                  icon: _deleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(_deleting ? 'Deleting…' : 'Delete event'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
