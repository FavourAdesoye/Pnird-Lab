<<<<<<< HEAD
import 'package:flutter/material.dart';  

class Studieshome extends StatelessWidget {

  const Studieshome({super.key});
 
  @override
  Widget build(context) {
    return const MaterialApp( 
      home: Studies()
    );
  }
}



class Studies extends StatelessWidget {
  const Studies({super.key});

  
@override
Widget build(BuildContext context){
  return const Scaffold( 
    backgroundColor: Colors.black, 
  ); 
}
}
=======
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
>>>>>>> main
