// ignore_for_file: prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pnirdlab/main_screen.dart';
import 'package:pnirdlab/pages/loginpages/staff_signup.dart';
import 'package:pnirdlab/pages/loginpages/staff_login.dart';
import 'package:pnirdlab/pages/loginpages/student_login.dart';
import 'package:pnirdlab/pages/loginpages/student_signup.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  //Ensure all bindings are initialized before running the app
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep splash screen while loading resources
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  try{
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAs4SE6TE1gccD76rC93BYShdZv27T8FZE",
            authDomain: "pnird-lab.firebaseapp.com",
            appId: "1:1060625556937:web:facd645c0df6912eadf418",
            storageBucket: "pnird-lab.firebasestorage.app",
            messagingSenderId: "1060625556937",
            measurementId: "G-G5JGKLPG9B",
            projectId: "pnird-lab"));
  } else {
    await Firebase.initializeApp();
  }
  print("Firebase Initialized successfully");
  } catch(e){
  print("Error initializing Firebase: $e");
  }
  
  // Simulating an authentication check
  bool isLoggedIn = await checkUserLoggedIn();
  //Run the app
  runApp(MyApp(isLoggedIn: isLoggedIn));

  // After initialization is complete, remove the splash screen
  FlutterNativeSplash.remove();
}

Future<bool> checkUserLoggedIn() async {
  // Here, you would implement the logic to check if the user is logged in
  // For demonstration purposes, let's return false (not logged in)
  await Future.delayed(Duration(seconds: 1)); // Simulate loading
  return false; // Change this based on your actual login state
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pnird Lab",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromRGBO(0, 0, 0, 1),
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Roboto',
            ),
      ),
      home: isLoggedIn ? MainScreenPage() : ChooseAccountTypePage(),
      routes: {
        '/student_signup': (context) => StudentSignUpPage(),
        '/student_login': (context) => StudentLoginPage(),
        '/staff_login': (context) => StaffLoginPage(),
        '/staff_signup': (context) => StaffSignUpPage(),
        '/home': (context) => MainScreenPage()
      },
    );
  }
}
