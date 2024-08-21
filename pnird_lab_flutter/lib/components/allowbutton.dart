import 'package:flutter/material.dart'; 

class AllowBtn extends StatelessWidget { 
  const AllowBtn({super.key, required this.btnText, required this.btnFun}); 
  final String btnText; 
  final Function btnFun; 
 

//creating the function for the button
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => btnFun(), 
    style: getBtnStyle(context), 
    child: Text(btnText),
    );
  } 

//creating the style for the button
  getBtnStyle(context) => ElevatedButton.styleFrom( 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
    backgroundColor: Colors.amber, 
    fixedSize:  Size(MediaQuery.of(context).size.width - 40,47), 
    textStyle: const TextStyle(fontWeight: FontWeight.normal,fontSize: 20)
  );

}