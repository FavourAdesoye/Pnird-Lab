import 'package:flutter/material.dart';

class StudiesPage extends StatefulWidget {
  StudiesPage({Key? key}) : super(key: key);

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
      child: Text("Create post"),
    )));
  }
}
