import 'package:flutter/material.dart'; 


//user interface
class EventInformation extends StatefulWidget {  
  final Map<String, dynamic> event;
  const EventInformation({super.key, required this.event});  


  @override
  // ignore: library_private_types_in_public_api
  _EventInformation createState() => _EventInformation();
  
} 


  class _EventInformation extends State<EventInformation> { 
  
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar( 
        title: Text(widget.event['titlepost'])), 

        body:  Padding( 
          padding: const EdgeInsets.all(16.0), 
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: <Widget>[ 
              Image.network(widget.event['image_url']), 
              const SizedBox(height: 16), 
              Text(
                widget.event['titlepost'], 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
              ), 
              const SizedBox(height: 8), 
              Text(
                 widget.event['caption'], 
                 style: const TextStyle(fontSize: 16)),

            ],
          )
        )
            
        );
  }  
  }