import 'dart:io';  
import 'package:image_picker/image_picker.dart';  

import 'package:flutter/material.dart';  
import 'package:flutternativesplash/components/allowbutton.dart';    
import 'package:flutternativesplash/screens/selectphoto.dart';
//import 'package:flutternativesplash/components/nextbutton.dart';

 
//void main() { 
 // runApp(const MaterialApp( 
  //  home: Allowaccess(),
 // ));
//}
class Allowaccess extends StatelessWidget {
  const Allowaccess({super.key});

  
@override
Widget build(BuildContext context){
  return const MaterialApp( 
    home: Allowaccess1(),
  );
}


 
}


class Allowaccess1 extends StatefulWidget { 
    const Allowaccess1({super.key});
 
  @override
  // ignore: library_private_types_in_public_api
  _Allowaccess createState() => _Allowaccess(); 
}
//user interface
 class _Allowaccess extends State<Allowaccess1>{ 

   File? image;
   //Get from gallery, loading images from the gallery

  Future<void> getFromGallery( BuildContext context) async {  

  try {  XFile? pickedFile = await ImagePicker().pickImage( 
      source: ImageSource.gallery, 
      maxWidth: 1800, 
      maxHeight: 1800,
    );   
    if (pickedFile != null) { 
      setState(() {
        image = File(pickedFile.path); 


      }); 
      
      if (mounted){
      Navigator.push( 
        // ignore: use_build_context_synchronously
        context, 
        MaterialPageRoute(builder: (context) =>   ViewImagePage(image: image)),
      ); 
      }
    }  
} catch (e) { 
  // ignore: avoid_print
  print("Error in gallery: $e");
} 
}
 
@override
Widget build(BuildContext context) {
   
//return MaterialApp(  
    //home: Scaffold( 
   return Scaffold( 
      backgroundColor: Colors.black, 
      appBar: AppBar( 
        backgroundColor: Colors.black, 
        leading: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            }, child: const Icon(Icons.close),
          ), 
          
        
      ),
      body: Center(   
      child: SingleChildScrollView(
      child:  Column( 
       mainAxisAlignment: MainAxisAlignment.center, 
       
       
        children: [ 
       
      
          const Padding(  
          padding: EdgeInsets.only(bottom: 10), 
          child: Text("Allow PNIRD to access your camera and microphone ", maxLines: 2, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)), 
          ), 
        
      
       // const Row(
       //  children: [ Padding( 
       //   padding: EdgeInsets.only(bottom: 15),
       //   child: Text("your camera and microphone", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30)) 
          
       // )]), 
          

        const Padding(
         padding:  EdgeInsets.only(bottom: 15),
         child: Text("How you'll use this", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)), 
         ),  

        const Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Text("To select photos and videos,and preview visual/audio effects", style: TextStyle(color: Color.fromARGB(255, 116, 111, 111), fontWeight:FontWeight.normal, fontSize: 15)), 
        ),

        const Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Text("How we'll use this", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)) 
        ), 

       const Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Text("To show you previews of visual and audio effects.", style: TextStyle(color: Color.fromARGB(255, 116, 111, 111), fontWeight:FontWeight.normal, fontSize: 15))
        ),
      
      AllowBtn( 
        btnFun: () => getFromGallery(context), 
        btnText: 'Continue', ),
      
        
    
      ],

       ) ,
       
      
      ), 
    ));
 // );
  
} 
 } 

