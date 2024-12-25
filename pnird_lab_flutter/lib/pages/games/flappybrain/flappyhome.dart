import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/games/chess/gameboard.dart';
import 'package:pnirdlab/pages/games/flappybrain/bird.dart';
import 'package:pnirdlab/pages/games/flappybrain/barries.dart';

import '../pickgame.dart';

class Flappyhome extends StatelessWidget {
  const Flappyhome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Homepage();
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  static double birdYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdYaxis;
  bool gamehasStarted = false;
  static double barrierXone = 0;
  double barrierXtwo = barrierXone + 1.5;
  int score = 0; // Track the current score

  // Reset game state
  void resetGame() {
    setState(() {
      birdYaxis = 0;
      time = 0;
      height = 0;
      initialHeight = birdYaxis;
      barrierXone = 0;
      barrierXtwo = barrierXone + 1.5;
      gamehasStarted = false;
      score = 0;
    });
  }

  // Function for the brain to jump
  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdYaxis;
    });
  }

  // Function to start the game
  void startGame() {
    gamehasStarted = true;
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      // Gravity equation
      time += 0.05;
      height = -4.9 * time * time + 2.8 * time;
      setState(() {
        birdYaxis = initialHeight - height;

        // Move barriers and update score
        if (barrierXone < -1.1) {
          barrierXone += 2;
          score++; // Increase score when the bird passes the first barrier
        } else {
          barrierXone -= 0.05;
        }

        if (barrierXtwo < -1.1) {
          barrierXtwo += 2;
          score++; // Increase score when the bird passes the second barrier
        } else {
          barrierXtwo -= 0.05;
        }
      });

      // End the game if the bird hits the ground
      if (birdYaxis > 1) {
        timer.cancel();
        gamehasStarted = false;
        showGameOverDialog(); // Show game over dialog
      }
    });
  }

  // Show game over dialog
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("Your Score: $score"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                resetGame(); // Reset the game
              },
              child: const Text("Play Again"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Gameboard()),
            );
              },
              child: const Text("Exit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flappy Brain", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Pickgame
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Pickgame()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (gamehasStarted) {
                      jump();
                    } else {
                      startGame();
                    }
                  },
                  child: AnimatedContainer(
                    alignment: Alignment(0, birdYaxis),
                    duration: const Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: const MyBird(),
                  ),
                ),
                Container(
                  alignment: const Alignment(0, -0.3),
                  child: gamehasStarted
                      ? const Text("")
                      : const Text(
                          "T A P  T O  P L A Y",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                ),
                AnimatedContainer(
                  alignment: Alignment(barrierXone, 1.1),
                  duration: const Duration(milliseconds: 0),
                  child: const MyBarrier(size: 200.0),
                ),
                AnimatedContainer(
                  alignment: Alignment(barrierXtwo, -1.1),
                  duration: const Duration(milliseconds: 0),
                  child: const MyBarrier(size: 250.0),
                ),
              ],
            ),
          ),
          Container(
            height: 15,
            color: Colors.green,
          ),
          Expanded(
            child: Container(
              color: Colors.brown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "SCORE",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        "$score",
                        style: const TextStyle(color: Colors.white, fontSize: 35),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
