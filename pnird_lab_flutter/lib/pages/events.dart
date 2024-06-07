import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EventsPage extends StatefulWidget {
  EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(
      "eventspage",
      style: TextStyle(fontSize: 60, color: Colors.amber),
    )));
  }
}
