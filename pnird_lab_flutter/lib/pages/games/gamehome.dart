import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pnirdlab/components/allowbutton.dart';
import 'package:pnirdlab/pages/games/pickgame.dart';

class Gamehome extends StatelessWidget {
  final File? image;

  const Gamehome({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Brain Train",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 245, 207, 40),
        automaticallyImplyLeading: false, // Remove back button since this is a main nav screen
      ),
      backgroundColor: Colors.black,
      body: const GamehomeContent(),
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
