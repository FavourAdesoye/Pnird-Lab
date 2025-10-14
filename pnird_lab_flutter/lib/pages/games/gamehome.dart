import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pnirdlab/components/allowbutton.dart';
import 'package:pnirdlab/pages/games/pickgame.dart';
import 'package:pnirdlab/pages/studies.dart';

class Gamehome extends StatelessWidget {
  final File? image;

  const Gamehome({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false,  home: _GamePage());
  }
}

class _GamePage extends StatefulWidget {
  const _GamePage();

  @override
  GameHomePage createState() => GameHomePage();
}

class GameHomePage extends State<_GamePage> {
  late final File? image;

  int currentIndex = 4; // Default to the Game page in the navigation bar
  final List<Widget> _screens = [
    // Replace these placeholders with actual pages as needed
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
    const GamehomeContent(), // The "Brain Train" screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        // Preserve widget state when navigating
        index: currentIndex,
        children: _screens,
      ),
    );
  }
}

class GamehomeContent extends StatelessWidget {
  const GamehomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset('assets/images/brain.png')),
            const SizedBox(height: 70),
            const Text(
              "Game Play",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "This section is designed to give your brain a break. We have implemented two different games you can choose to play.",
                maxLines: 3,
                style: TextStyle(
                  color: Color.fromARGB(255, 245, 207, 40),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            AllowBtn(
              btnText: 'Game Play!',
              btnFun: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Pickgame(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
