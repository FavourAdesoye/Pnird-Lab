import 'package:flutter/material.dart';
import "package:pnirdlab/pages/games/flappybrain/flappyhome.dart";
import 'chess/gameboard.dart';

class Pickgame extends StatelessWidget {
  const Pickgame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Choose a game",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 245, 207, 40),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context); // Properly exit back to previous screen
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(),
        child: const Center(child: CardExample()),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Gameboard()),
                );
              },
              child: const SizedBox(
                width: 300,
                height: 100,
                child: Center(
                  child: Text(
                    'Chess',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Card(
            color: const Color.fromARGB(255, 245, 207, 40),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Flappyhome()),
                );
              },
              child: const SizedBox(
                width: 300,
                height: 100,
                child: Center(
                  child: Text(
                    'Flappy Brain',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ]));
  }
}
