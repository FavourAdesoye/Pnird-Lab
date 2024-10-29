import 'package:flutter/material.dart';

class StudiesPage extends StatefulWidget {
  const StudiesPage({super.key});

  @override
  _StudiesPageState createState() => _StudiesPageState();
}

class _StudiesPageState extends State<StudiesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      onPressed: () {},
      child: const Text("Create post"),
    )));
  }
}
