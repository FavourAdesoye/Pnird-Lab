import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
            child: Text(
      "studies",
      style: TextStyle(fontSize: 60, color: Colors.amber),
    )));
  }
}
