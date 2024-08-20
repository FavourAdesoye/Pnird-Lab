import 'package:flutter/material.dart';
import 'pages/dms.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto',
      scaffoldBackgroundColor: Colors.black),
      home: const DmsPage(),
    );
  }
}
