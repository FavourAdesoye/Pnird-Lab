import 'package:flutter/material.dart';  

class Homehome extends StatelessWidget {

  const Homehome({super.key});
 
  @override
  Widget build(context) {
    return const MaterialApp( 
      home: Home()
    );
  }
}





class Home extends StatelessWidget {
  const Home({super.key});

  
@override
Widget build(BuildContext context){
  return const Scaffold( 
        backgroundColor: Colors.black, 
  ); 
}
}