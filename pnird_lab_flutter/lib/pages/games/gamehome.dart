// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pnirdlab/components/allowbutton.dart';
import 'package:pnirdlab/pages/games/pickgame.dart';
import 'package:pnirdlab/pages/studies.dart';

class Gamehome extends StatelessWidget {
  final File? image;

  const Gamehome({super.key, this.image});

  @override
  Widget build(context) {
    return MaterialApp(home: _GamePage());
  }
}

class _GamePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  GameHomePage createState() => GameHomePage();
}

// ignore: must_be_immutable
class GameHomePage extends State<_GamePage> {
  late final File? image;

  int currentIndex = 3; // Set to 3 to default to the GamePage
  final List<Widget> _screens = [
    //const Homehome(),
    StudiesPage(),
//const EventsHome(),
    //const Abouthome(),
    const Gamehome(),
  ];

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    return Scaffold(
      //  home: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            icon: const Icon(Icons.close),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Image.asset('assets/images/brain.png')),
                  const SizedBox(height: 70),
                  const Text(
                    "Brain Train",
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "This section is designed to help train your brain. We have implemented three different games you can choose to play.",
                      maxLines: 3,
                      style: TextStyle(
                          color: Color.fromARGB(255, 245, 207, 40),
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AllowBtn(
                    btnText: 'Train Your Brain!',
                    btnFun: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Pickgame())),
                  )
                ],
              ))),
    );

    //  );
  }
}
