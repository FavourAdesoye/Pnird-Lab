<<<<<<< HEAD
import 'dart:convert';  
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http; 

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});
 
  @override
  // ignore: library_private_types_in_public_api
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> { 
  List events = []; 

  @override
  void initState () { 
    super.initState(); 
    fetchEvents();
  } 


  fetchEvents() async { 
    final response = await http.get(Uri.parse('http://localhost:5000/eventregistration/events')); 

    if(response.statusCode == 200){ 
      setState(() {
        events = json.decode(response.body);
      }); 
    } else { 
      throw Exception('Failed to load events');
    }
  } 

  @override
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Events'),), 

        body: ListView.builder(
          itemCount: events.length, 
          itemBuilder: (context, index) { 
            return ListTile( 
              leading: Image.network(events[index]['image_url']), 
              title: Text(events[index]['titlepost']), 
              subtitle: Text(events[index]['caption']),
            );
          }
        )
    ); 
    
  }
}
=======
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
>>>>>>> main
