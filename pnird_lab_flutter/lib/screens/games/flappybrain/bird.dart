import 'package:flutter/material.dart'; 

class MyBird extends StatelessWidget {
  const MyBird({super.key});
 
  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container( 
      height: 60, 
      width: 60,
      child: Image.asset( 
        'assets/images/flappybrain.png'
      )
    );
  }
}