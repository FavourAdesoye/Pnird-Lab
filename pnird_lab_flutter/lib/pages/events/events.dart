import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/events/NetworkHandler.dart';
import 'package:pnirdlab/pages/events/events1.dart';
import 'package:pnirdlab/pages/games/gamehome.dart';
import 'package:pnirdlab/pages/studies.dart';

class EventsHome extends StatelessWidget {
  const EventsHome({super.key});

  @override
  Widget build(context) {
    return MaterialApp(home: _EventsPage());
  }
}

class _EventsPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<_EventsPage> {
  List events = [];
  NetworkHandler networkHandler = NetworkHandler();
  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  fetchEvents() async {
    try {
      var response = await networkHandler.get("/eventregistration/events");
      if (response != null) {
        setState(() {
          events = response;
        });
      }
    } catch (e) {
      print("Error during HTTP request: $e");
      throw Exception("Failed to load events");
    }
  }

  //once they click on one the image events, it will navigate to show more information about the event
  Future<void> eventinformation(
      BuildContext context, Map<String, dynamic> event) async {
    try {
      if (mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventInformation(event: event),
            ));
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error in gallery: $e");
    }
  }

  Widget eventWidget(BuildContext context, String titlepost, String caption,
      String imageUrl, Map<String, dynamic> event) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: GestureDetector(
                    onTap: () => eventinformation(context, event),
                    child: Image.asset(imageUrl)),
              ),
              Text(
                titlepost,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ]));
  }

  int currentIndex = 2; // Set to 2 to default to the EventsPage
  final List<Widget> _screens = [
    //const Homehome(),
    StudiesPage(),
    _EventsPage(),
    //const Abouthome(),
    const Gamehome(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ),
      body: ListView.builder(
          prototypeItem: const Divider(height: 1, color: Colors.grey),
          itemCount: events.length,
          itemBuilder: (BuildContext context, int index) {
            var eventItem = events[index];

            return eventWidget(
              context,
              networkHandler.formater(eventItem['image_url']),
              eventItem['titlepost'],
              eventItem['caption'],
              eventItem,
            );
          }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.library_books,
            ),
            label: 'Studies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'About Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Game',
          ),
        ],
      ),
    );
  }
}
