// ignore_for_file: prefer_const_declarations, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pnirdlab/pages/events_detail_page.dart';

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

  @override
  void initState() {
    super.initState();
    // Fetch events for the default month
    fetchAllEvents();
  }

  Future<List<dynamic>> fetchEvents(String url) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
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
    final url = 'http://10.0.2.2:3000/api/events/events/';
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
      final url = 'http://10.0.2.2:3000/api/events/event/$month';
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
    List upcomingEvents = getUpcomingEvents();
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Events",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
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
                          border: Border.all(color: Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            months[index],
                            style: TextStyle(
                              color: selectedMonthIndex == index
                                  ? Colors.white
                                  : Colors.grey,
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
                  : events.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(16.0),
                          child: const Center(
                              child: Text(
                                  "There are no events this month at the moment. ",
                                  style: TextStyle(color: Colors.white))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable scroll to avoid conflicts
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to the event detail page when a card is tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EventDetailPage(event: event),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Event Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      child: Image.network(
                                        event["image_url"],
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
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            event["description"] ??
                                                'No Description',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            formattedDateTime(DateTime.parse(
                                                event["dateofevent"])),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
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
                  ? Center(child: CircularProgressIndicator())
                  : selectedMonthIndex == 0
                      ? SizedBox.shrink()
                      : upcomingEvents.isEmpty && selectedMonthIndex != 0
                          ? Center(
                              child: Text("No upcoming events.",
                                  style: TextStyle(color: Colors.white)),
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
                                        color: Colors.white),
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: upcomingEvents.length,
                                    itemBuilder: (context, index) {
                                      final event = upcomingEvents[index];
                                      return GestureDetector(
                                        onTap: () {
                                          // Navigate to the event detail page when a card is tapped
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EventDetailPage(event: event),
                                            ),
                                          );
                                        },
                                        child: ListTile(
                                          leading: Image.network(
                                            event[
                                                'image_url'], // Access 'image_url' from the event object
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit
                                                .cover, // Ensure the image fits properly
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                Icon(Icons
                                                    .image), // Handle image loading errors
                                          ),
                                          title: Text(
                                            event['titlepost'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            formattedDateTime(DateTime.parse(
                                                event["dateofevent"])),
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          trailing: Icon(Icons.arrow_forward),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
            ],
          ),
        ));
  }
}
