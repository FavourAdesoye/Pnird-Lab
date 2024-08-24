import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pnird_lab_flutter/main_screen.dart';
import 'pages/dms.dart';
import 'package:flutternativesplash/components/button_controller.dart'; 
import 'package:flutternativesplash/screens/games/gamehome.dart';
import 'package:get/get.dart';



void main() async {
  //Ensure all bindings are initialized before running the app
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep splash screen while loading resources
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //Run the app
  runApp(MyApp());
  // After initialization is complete, remove the splash screen
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget { 
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(  
      title: "Pnird Lab",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromRGBO(0, 0, 0, 1),
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Roboto',
            ),
      ),
      home: MainScreenPage(),
    );
  }
} 
