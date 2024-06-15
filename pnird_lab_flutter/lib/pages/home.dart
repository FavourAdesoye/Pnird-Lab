import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pnird_lab_flutter/widgets/post_card.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PostCard(),
    );
  }
}
