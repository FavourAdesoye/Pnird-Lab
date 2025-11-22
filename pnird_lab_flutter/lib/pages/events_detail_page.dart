import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatelessWidget {
  final dynamic event;

  const EventDetailPage({super.key, required this.event});
  String formattedDateTime(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          event['titlepost'].toString().capitalize(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              event['image_url'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            Text(
              event['description'] ?? 'No description available.',
              style: const TextStyle(
                fontSize: 17,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Event Date: ${formattedDateTime(DateTime.parse(event["dateofevent"]).toLocal())}",
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Event Time: ${event['timeofevent'] != null ? DateFormat('hh:mm a').format(DateTime.parse('1970-01-01 ${event['timeofevent']}')) : 'TBD'}",
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
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
