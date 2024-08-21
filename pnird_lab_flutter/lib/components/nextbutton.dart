import 'package:flutter/material.dart'; 

class NextBtn extends StatelessWidget { 
  const NextBtn({super.key, required this.btnnext, required this.nextText}); 
  final String nextText; 
  final Function btnnext; 
 

//creating the function for the button
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => btnnext(), 
    style: getBtnStyle(context), 
    child: Text(nextText),
    );
  } 

//creating the style for the button
  getBtnStyle(context) => ElevatedButton.styleFrom( 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
    backgroundColor: Colors.yellow, 
    fixedSize:  Size(MediaQuery.of(context).size.width - 20,27), 
    textStyle: const TextStyle(fontWeight: FontWeight.normal,fontSize: 20)
  );

}