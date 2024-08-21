import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutternativesplash/screens/games/flappybrain/bird.dart';

class Flappyhome extends StatelessWidget {
  const Flappyhome({super.key});
 
  @override
    
    Widget build(BuildContext context) { 
      return const MaterialApp( 
       // debugShowCheckedModeBanner: false, 
        home: Homepage(),
      );
    }
  } 

class Homepage extends StatefulWidget {
  const Homepage({super.key});
 
  @override
    // TODO: implement createElement
    // ignore: library_private_types_in_public_api
    _HomepageState createState() => _HomepageState(); 

  
} 

class _HomepageState extends State<Homepage> {   
  /*#height of flappy brain*/
  static double birdYaxis = 0; 
  double time = 0; 
  double height = 0; 
  double initialHeight = birdYaxis;
  bool gamehasStarted = false;
  //function for the brain to jump 
  void jump () { 
    setState(() { 
      time = 0; 
      initialHeight = birdYaxis;
    });
  } 

  void startGame() {  
    gamehasStarted = true;
    Timer.periodic(const Duration(milliseconds: 60), (timer){ 
   //this equation is used to make sure the when the brain is being tapped on it is to reflect gravity
    time += 0.05 ;
    height = -4.9 * time * time * 2.8 * time;
    setState(() { 
      birdYaxis = initialHeight - height; 
    });  
    if (birdYaxis > 0) { 
      timer.cancel(); 
      gamehasStarted = false;
    }
    });
  }


  @override 
  Widget build(BuildContext context) 
  { 
    return Scaffold( 
      body: Column(
        children: [ 
          Expanded(  
            flex: 2, 
            /*an animated container is used so the brain is able to move*/ 
            child: GestureDetector( 
              onTap: () { 
                if (gamehasStarted) { 
                  jump();
                } else { 
                  startGame();
                }
              },
            child: AnimatedContainer(  
              alignment: const Alignment(0,0),
              duration: const Duration(milliseconds: 0),
              color: Colors.blue, 
              child: const MyBird(), 
            ))), 
            Expanded( child: Container(
            color: Colors.green,))
        ]
        ,)
    );
  } 
} 
