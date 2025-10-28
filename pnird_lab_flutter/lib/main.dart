// ignore_for_file: prefer_const_constructors
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnirdlab/main_screen.dart';
import 'package:pnirdlab/pages/loginpages/staff_signup.dart';
import 'package:pnirdlab/pages/loginpages/staff_login.dart';
import 'package:pnirdlab/pages/loginpages/student_login.dart';
import 'package:pnirdlab/pages/loginpages/student_signup.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
// import 'package:firebase_core/firebase_core.dart';


void main() async {
  //Ensure all bindings are initialized before running the app
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep splash screen while loading resources
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: ".env");
      print("Environment variables loaded successfully");
    } catch (e) {
      print("Error loading environment variables: $e");
    }
  } else {
    print("Skipping environment variable loading for web build");
  }
  // Firebase initialization removed for now
  print("App initialized without Firebase");
  
  // Simulating an authentication check
  bool isLoggedIn = await checkUserLoggedIn();
  //Run the app
  runApp(MyApp(isLoggedIn: isLoggedIn));

  // After initialization is complete, remove the splash screen
  FlutterNativeSplash.remove();
}

Future<bool> checkUserLoggedIn() async {
  // Check if user is logged in using SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final email = prefs.getString('email');
    final role = prefs.getString('role');
    
    // User is logged in if we have all required data
    return userId != null && email != null && role != null;
  } catch (e) {
    print("Error checking login state: $e");
    return false;
  }
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
