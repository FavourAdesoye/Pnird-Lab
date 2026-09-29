// ignore_for_file: prefer_const_declarations, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/services/api_service.dart';
import 'package:pnirdlab/pages/events_detail_page.dart';
import 'package:pnirdlab/pages/create_events_page.dart';
import 'package:pnirdlab/widgets/optimized_image.dart';
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  // State variables
  int selectedMonthIndex = 0;

  final List<String> months = [
    "All",
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  List<dynamic> events = [];
  List<dynamic> allEvents = []; // Store all events

  bool isLoading = true;
  bool _isStaff = false; // Track if user is staff/admin
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    // Fetch events for the default month
    fetchAllEvents();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    setState(() {
      _isStaff = role == 'staff';
    });
  }

  Future<List<dynamic>> fetchEvents(String url) async {
    setState(() {
      isLoading = true;
      _loadError = null;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);
        // Sort by createdAt descending (newest first)
        events.sort((a, b) {
          final dateA = a['createdAt'] != null ? DateTime.parse(a['createdAt']) : DateTime(1970);
          final dateB = b['createdAt'] != null ? DateTime.parse(b['createdAt']) : DateTime(1970);
          return dateB.compareTo(dateA); // Descending order (newest first)
        });
        return events;
      }
      setState(() {
        _loadError = 'Could not load events (${response.statusCode}).';
      });
    } catch (e) {
      setState(() {
        _loadError = 'Could not load events. Check your connection and try again.';
      });
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return [];
  }

  String formattedDateTime(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  Future<void> fetchAllEvents() async {
    final url = '${ApiService.baseUrl}/events/events/';
    final data = await fetchEvents(url);
    setState(() {
      allEvents = data;
      events = data;
    });
  }

  Future<void> fetchEventsForMonth(String month) async {
    if (month == "All") {
      // Show all events if "All" is selected
      setState(() {
        events = allEvents;
      });
    } else {
      // Fetch events for the specific month
      final url = '${ApiService.baseUrl}/events/event/$month';
      final data = await fetchEvents(url);
      setState(() {
        events = data;
      });
    }
  }

  List<dynamic> getUpcomingEvents() {
    if (selectedMonthIndex == 0) {
      // If "All" is selected, show all events
      return [];
    }
    return allEvents.where((event) {
      final eventMonthIndex = months.indexOf(event["month"]);
      return eventMonthIndex > selectedMonthIndex;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.65);
    final chipBorder = theme.brightness == Brightness.dark ? Colors.white54 : Colors.black26;
    List upcomingEvents = getUpcomingEvents();
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Events",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMonthIndex = index;
                        });
                        fetchEventsForMonth(months[selectedMonthIndex]);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selectedMonthIndex == index
                              ? Colors.purple
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: chipBorder),
                        ),
                        child: Center(
                          child: Text(
                            months[index],
                            style: TextStyle(
                              color: selectedMonthIndex == index
                                  ? Colors.white
                                  : muted,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Event List
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                      ? Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                              const SizedBox(height: 12),
                              Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: onSurface),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: fetchAllEvents,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                  : events.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                              child: Text(
                                  "There are no events this month at the moment.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable scroll to avoid conflicts
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return GestureDetector(
                              onTap: () async {
                                final deleted = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailPage(event: event),
                                  ),
                                );
                                if (deleted == true) fetchAllEvents();
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: chipBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Event Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      child: OptimizedImage(
                                        imageUrl: event["image_url"]?.toString() ?? '',
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    // Event Info
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event["titlepost"] ?? 'No Title',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            event["description"] ??
                                                'No Description',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: muted,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            formattedDateTime(DateTime.parse(
                                                event["dateofevent"]).toLocal()),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              isLoading
                  ? const SizedBox.shrink()
                  : selectedMonthIndex == 0
                      ? const SizedBox.shrink()
                      : upcomingEvents.isEmpty && selectedMonthIndex != 0
                          ? Center(
                              child: Text("No upcoming events.",
                                  style: TextStyle(color: muted)),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Upcoming Events",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: onSurface),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: upcomingEvents.length,
                                    itemBuilder: (context, index) {
                                      final event = upcomingEvents[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          final deleted = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EventDetailPage(event: event),
                                            ),
                                          );
                                          if (deleted == true) fetchAllEvents();
                                        },
                                        child: ListTile(
                                          leading: OptimizedImage(
                                            imageUrl: event['image_url']?.toString() ?? '',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorWidget: const Icon(Icons.image),
                                          ),
                                          title: Text(
                                            event['titlepost']?.toString() ?? 'Untitled event',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            formattedDateTime(DateTime.parse(
                                                event["dateofevent"]).toLocal()),
                                            style:
                                                TextStyle(color: muted),
                                          ),
                                          trailing: const Icon(Icons.arrow_forward),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
            ],
          ),
        ),
        floatingActionButton: _isStaff
            ? FloatingActionButton(
                heroTag: 'events_fab',
                onPressed: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateEventPage()),
                  );
                  if (created == true) fetchAllEvents();
                },
                tooltip: 'Create New Event',
                child: const Icon(Icons.add),
              )
            : null,
    );
  }
}
