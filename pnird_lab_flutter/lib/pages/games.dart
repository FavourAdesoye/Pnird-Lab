import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Text(
      "gamespage",
      style: TextStyle(fontSize: 60, color: Colors.amber),
    )));
  }
}
