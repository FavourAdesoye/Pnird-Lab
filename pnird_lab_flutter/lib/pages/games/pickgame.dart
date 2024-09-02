import 'package:flutter/material.dart';
import 'package:pnirdlab/pages/games/chess/chess1.dart';
import 'package:pnirdlab/pages/games/gamehome.dart';
import "package:pnirdlab/pages/games/flappybrain/flappyhome.dart";

class Pickgame extends StatelessWidget {
  const Pickgame({super.key});

  @override
  Widget build(context) {
    return MaterialApp(home: _Pickgame());
  }
}

class _Pickgame extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _Pickgamepage createState() => _Pickgamepage();
}

class _Pickgamepage extends State<_Pickgame> {
  @override
  Widget build(BuildContext build) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Choose a game",
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 245, 207, 40),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              color: Colors.white,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Gamehome()));
              }),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_forward_outlined),
              color: Colors.white,
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
              //gradient: RadialGradient(
              //  colors: [
              //    Color(0x00000000),
              //    Color(0xfff5cf28)
              //    ]
              ///)
              ),
          child: const Center(child: CardExample()),
        ));
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
            // clipBehavior is necessary because, without it, the InkWell's animation
            // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
            // This comes with a small performance cost, and you should not set [clipBehavior]
            // unless you need it.
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                  width: 300,
                  height: 100,
                  child: Center(
                    child: Text(
                      'Color Switch',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 50),
          Card(
            color: const Color.fromARGB(255, 245, 207, 40),
            // clipBehavior is necessary because, without it, the InkWell's animation
            // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
            // This comes with a small performance cost, and you should not set [clipBehavior]
            // unless you need it.
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const ChessHome()));
              },
              child: const SizedBox(
                  width: 300,
                  height: 100,
                  child: Center(
                    child: Text(
                      'Chess',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 50),
          Card(
            color: const Color.fromARGB(255, 245, 207, 40),
            // clipBehavior is necessary because, without it, the InkWell's animation
            // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
            // This comes with a small performance cost, and you should not set [clipBehavior]
            // unless you need it.
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Flappyhome()));
              },
              child: const SizedBox(
                  width: 300,
                  height: 100,
                  child: Center(
                    child: Text(
                      'Flappy Brain',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )),
            ),
          ),
        ]));
  }
}
