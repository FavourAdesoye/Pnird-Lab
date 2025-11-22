import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class EventDetailPage extends StatefulWidget {
  final dynamic event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  String formattedDateTime(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String _getEventTime() {
    // Check both possible field names (for backward compatibility)
    final time = widget.event['timeofevent'] ?? widget.event['timeofEvent'];
    
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
      final eventDate = DateTime.parse(widget.event['dateofevent']).toLocal();
      
      // Parse the time if available (check both field names for backward compatibility)
      final timeString = widget.event['timeofevent'] ?? widget.event['timeofEvent'];
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
      title: widget.event['titlepost'] ?? 'Event',
      description: widget.event['description'] ?? '',
      location: widget.event['location'] ?? '',
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
        title: Text(
          widget.event['titlepost'].toString().capitalize(),
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
            Image.network(
              widget.event['image_url'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              widget.event['description'] ?? 'No description available.',
              style: TextStyle(
                fontSize: 17,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Event Date: ${formattedDateTime(DateTime.parse(widget.event["dateofevent"]).toLocal())}",
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
            if (widget.event['location'] != null && widget.event['location'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "Location: ${widget.event['location']}",
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
