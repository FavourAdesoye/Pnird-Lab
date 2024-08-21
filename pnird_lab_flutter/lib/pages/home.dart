<<<<<<< HEAD
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
=======
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
>>>>>>> main
