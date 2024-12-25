import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/games/chess/gameboard.dart';
import 'package:pnirdlab/pages/games/pickgame.dart';
import '../../studies.dart';

class ChessHowtoplay extends StatelessWidget {
  const ChessHowtoplay({super.key});

  @override
  Widget build(BuildContext context) {
    return _ChessHowtoplay();
  }
}

class _ChessHowtoplay extends StatefulWidget {
  @override
  _ChessHowtoplaypage createState() => _ChessHowtoplaypage();
}

class _ChessHowtoplaypage extends State<_ChessHowtoplay> {
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
    const ChessHowtoplaypage(), // 
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

class ChessHowtoplaypage extends StatelessWidget {
  const ChessHowtoplaypage({super.key});

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
              MaterialPageRoute(builder: (context) => const Pickgame()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Gameboard()),
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
                          "Chess is a two-player strategy game played on an 8x8 board."
                          "The goal is to checkmate your opponent's king by placing it under attack with no escape." 
                          "Pieces will be highlighted in green to let you know where you are able to move the piece"
                          " Each piece moves differently: pawns move forward, bishops diagonally, rooks straight, knights in an L-shape,queens in all directions, and kings one square." 
                          " The game ends in a win with checkmate, or a draw through stalemate or agreement.", 
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
