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