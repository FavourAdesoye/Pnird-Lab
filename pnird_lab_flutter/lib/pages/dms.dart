import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

class DmsPage extends StatelessWidget {
  const DmsPage ({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
    
      body: Column(
        
        children: [
          Container(
            
            height: 30,
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.20),
                  blurRadius: 40,
                  spreadRadius: 0.0,
                )
              ]
            ),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))
              ),
            ),
           
          ),

          Container(
            height: 30,
            width: 115,

            margin: EdgeInsets.only(top:20, left: 20, right: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
                boxShadow: [
                BoxShadow(
                  color: Color(0xffFFC700),
                  blurRadius: 0,
                  spreadRadius: 0.0,
                )
              ]
            ),
            child: const Row(children: <Widget>[
              Text('      Messages', style: TextStyle( 
                color: Colors.white, 
                fontWeight: FontWeight.bold,
              ),
            
              
              ),

              
            

            ],)
          ),

          Container(
            height: 75,
            margin: EdgeInsets.only(top: 20, left: 25, right:25),
            decoration: BoxDecoration(
              // border: Border.all(width: 5, color: Color.fromARGB(255, 101, 101, 101)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 66, 66, 66),

                )
              ]
            ),
            child: const ListTile(
              title: Text(
                'Username',
                  style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
),
              ),
              subtitle: Text('5m',
              style: TextStyle(color: Colors.grey ),
              textAlign: TextAlign.right,
              ),
              leading: CircleAvatar(backgroundColor: Colors.blue, radius: 30,),
            
            ),
          ),
          Container(
            height: 75,
            margin: EdgeInsets.only(top: 30, left: 25, right:25),
            decoration: BoxDecoration(
              // border: Border.all(width: 5, color: Color.fromARGB(255, 101, 101, 101)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 66, 66, 66),

                )
              ]
            ),
            child: const ListTile(
              title: Text(
                'Username',
                  style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
),
              ),
              subtitle: Text('14h',
              style: TextStyle(color: Colors.grey ),
              textAlign: TextAlign.right,
              ),
              leading: CircleAvatar(backgroundColor: Colors.pink, radius: 30,),
            
            ),
          ),
          Container(
            height: 75,
            margin: EdgeInsets.only(top: 30, left: 25, right:25),
            decoration: BoxDecoration(
              // border: Border.all(width: 5, color: Color.fromARGB(255, 101, 101, 101)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 66, 66, 66),

                )
              ]
            ),
            child: const ListTile(
              title: Text(
                'Username',
                  style: TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
),
              ),
              subtitle: Text('2d',
              style: TextStyle(color: Colors.grey ),
              textAlign: TextAlign.right,
              ),
              leading: CircleAvatar(backgroundColor: Colors.red, radius: 30,),
            
            ),
          )
        ],
        ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: const Text(
        
        'Direct Messages',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black
      )
      ),
      centerTitle: true,
      backgroundColor:  Color(0xffFFC700),
      leading: Container(
        margin: EdgeInsets.all(10),

        decoration: BoxDecoration(
          color: Color.fromARGB(255, 0, 0, 0),
          borderRadius: BorderRadius.circular(10)
        ),
      ),
    );
  }
}