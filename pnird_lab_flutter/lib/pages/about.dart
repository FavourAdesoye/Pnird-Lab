import 'package:flutter/material.dart';  


class Abouthome extends StatelessWidget {

  const Abouthome({super.key});
 
  @override
  Widget build(context) {
    return const MaterialApp( 
      home: About()
    );
  }
}





class About extends StatelessWidget {
  const About({super.key});

  
@override
Widget build(BuildContext context){
  return const Scaffold( 
        backgroundColor: Colors.black, 

  ); 
}
}