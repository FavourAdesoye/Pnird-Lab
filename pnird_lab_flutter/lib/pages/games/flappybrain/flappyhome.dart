import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/games/flappybrain/bird.dart';
import 'package:pnirdlab/pages/games/flappybrain/barries.dart';

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

        if (barrierXone < -1.1) {
          barrierXone += 2;
        } else {
          barrierXone -= 0.05;
        }

        if (barrierXtwo < -1.1) {
          barrierXtwo += 2;
        } else {
          barrierXtwo -= 0.05;
        }
      });

      if (birdYaxis > 1) {
        timer.cancel();
        gamehasStarted = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    children: const [
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
                    children: const [
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
