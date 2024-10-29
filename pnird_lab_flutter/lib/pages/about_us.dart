import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Text(
      "about us",
      style: TextStyle(fontSize: 60, color: Colors.yellow),
    )));
  }
}
