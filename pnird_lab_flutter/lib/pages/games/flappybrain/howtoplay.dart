import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/games/gamehome.dart';
import "package:pnirdlab/pages/games/flappybrain/flappyhome.dart";
import '../../studies.dart';

class Howtoplay extends StatelessWidget {
  const Howtoplay({super.key});

  @override
  Widget build(BuildContext context) {
    return _Howtoplay();
  }
}

class _Howtoplay extends StatefulWidget {
  @override
  _Howtoplaypage createState() => _Howtoplaypage();
}

class _Howtoplaypage extends State<_Howtoplay> {
  int currentIndex = 4; // Default to the Game page in the navigation bar
  final List<Widget> _screens = [
    const Placeholder(
      child: Center(child: Text('Home Page')), // Placeholder for Home
    ),
     const StudiesPage(),
    const Placeholder(
      child: Center(child: Text('Events Page')), // Placeholder for Events
    ),
    const Placeholder(
      child: Center(child: Text('About Us Page')), // Placeholder for About Us
    ),
    const Howtoplaypage(), // 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
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

class Howtoplaypage extends StatelessWidget {
  const Howtoplaypage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "How to Play",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 245, 207, 40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Gamehome()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Flappyhome()),
            );
            },
            icon: const Icon(Icons.arrow_forward_outlined),
            color: Colors.white,
          )
        ],
      ),
        body: const Column(
        children: [
          SizedBox(height: 150), // Adds space between the AppBar and the Card
          Expanded(
            child: CardExample(),
          ),
        ],
      ),
    );
  }
}

class CardExample extends StatelessWidget {
  const CardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Card(
            color: const Color.fromARGB(255, 245, 207, 40),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              child: Container(
                padding: const EdgeInsets.all(16), // Optional: Adds padding inside the card
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage('assets/images/group.png'), // Replace with your image path
                        width: 80, // Set the desired width
                        height: 80, // Set the desired height
                      ),
                      SizedBox(width: 10), // Space between image and text
                      Expanded(
                        child: Text(
                          "This is a spin off of the game flappy bird."
                          "The goal is to make the bird fly as far as possible." 
                          "You can make the bird jump by tapping on the screen. "
                          "The goal is to keep the bird in the air as long as possible."
                          "If you hit a pole or stop tapping, the bird will fall.",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.left, // Align text
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20), // Adds spacing below the card
          Expanded(
            child: Container(
              // Flexible container to prevent overflow
              color: Colors.transparent, // Replace with a background color if needed
            ),
          ),
        ],
      ),
    );
  }
}
