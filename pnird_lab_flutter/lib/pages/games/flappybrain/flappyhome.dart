import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/games/flappybrain/bird.dart';
import 'package:pnirdlab/pages/games/flappybrain/barries.dart';

import '../gamehome.dart';
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


  // --- Add this collision check function ---
  bool checkCollision() {
    // Bird's horizontal position is always 0 (center)
    const double birdX = 0;
    const double birdWidth = 0.1; // Adjust as needed
    const double birdHeight = 0.1; // Adjust as needed

    // Barrier sizes and positions
    const double barrierWidth = 0.2; // Adjust as needed
    // Barrier 1 (bottom)
    double barrier1X = barrierXone;
    double barrier1Y = 1.1;
    double barrier1Height = 100 / 300 * 2; // 100 is size, 300 is screen units, *2 for [-1,1] range

    // Barrier 2 (top)
    double barrier2X = barrierXtwo;
    double barrier2Y = -1.1;
    double barrier2Height = 150 / 300 * 2; // 150 is size

    // Bird's bounding box
    double birdTop = birdYaxis - birdHeight / 2;
    double birdBottom = birdYaxis + birdHeight / 2;
    double birdLeft = birdX - birdWidth / 2;
    double birdRight = birdX + birdWidth / 2; 

    // Barrier 1 bounding box (bottom)
    double barrier1Top = barrier1Y - barrier1Height;
    double barrier1Bottom = barrier1Y;
    double barrier1Left = barrier1X - barrierWidth / 2;
    double barrier1Right = barrier1X + barrierWidth / 2;

    // Barrier 2 bounding box (top)
    double barrier2Top = barrier2Y;
    double barrier2Bottom = barrier2Y + barrier2Height;
    double barrier2Left = barrier2X - barrierWidth / 2;
    double barrier2Right = barrier2X + barrierWidth / 2;

    // Check collision with barrier 1 (bottom)
    bool collide1 = birdRight > barrier1Left &&
        birdLeft < barrier1Right &&
        birdBottom > barrier1Top &&
        birdTop < barrier1Bottom;

    // Check collision with barrier 2 (top)
    bool collide2 = birdRight > barrier2Left &&
        birdLeft < barrier2Right &&
        birdBottom > barrier2Top &&
        birdTop < barrier2Bottom; 
     return collide1 || collide2;
  }

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

      // --- Add collision check here ---
      if (checkCollision()) {
        timer.cancel();
        gamehasStarted = false;
        showGameOverDialog();
      }
      // --- End collision check ---

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
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to game selection
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
        title:
            const Text("Flappy Brain", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Pickgame
            Navigator.pop(context);
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
                  child: const MyBarrier(size: 100.0),
                ),
                AnimatedContainer(
                  alignment: Alignment(barrierXtwo, -1.1),
                  duration: const Duration(milliseconds: 0),
                  child: const MyBarrier(size: 150.0),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "SCORE",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        "0",
                        style: TextStyle(color: Colors.white, fontSize: 35),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "BEST",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        "10",
                        style: TextStyle(color: Colors.white, fontSize: 35),
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
