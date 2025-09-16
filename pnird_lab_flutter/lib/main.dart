// ignore_for_file: prefer_const_constructors
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:pnirdlab/main_screen.dart';
import 'package:pnirdlab/pages/loginpages/staff_signup.dart';
import 'package:pnirdlab/pages/loginpages/staff_login.dart';
import 'package:pnirdlab/pages/loginpages/student_login.dart';
import 'package:pnirdlab/pages/loginpages/student_signup.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:pnirdlab/pages/loginpages/email_verification_page.dart';
import 'package:pnirdlab/pages/loginpages/email_test_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pnirdlab/services/auth.dart';
import 'package:pnirdlab/providers/theme_provider.dart';
import 'package:pnirdlab/theme/app_theme.dart';


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
  try {
    // Check if user is logged in using the new auth service
    return await Auth.isLoggedIn();
  } catch (e) {
    print('Error checking login state: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: "Pnird Lab",
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: AppTheme.lightTheme.textTheme.apply(
                fontFamily: 'Roboto',
              ),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: AppTheme.darkTheme.textTheme.apply(
                fontFamily: 'Roboto',
              ),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: isLoggedIn ? MainScreenPage() : ChooseAccountTypePage(),
            routes: {
              '/student_signup': (context) => StudentSignUpPage(),
              '/student_login': (context) => StudentLoginPage(),
              '/staff_login': (context) => StaffLoginPage(),
              '/staff_signup': (context) => StaffSignUpPage(),
              '/email_verification': (context) => EmailVerificationPage(email: ''),
              '/email_test': (context) => EmailTestPage(),
              '/home': (context) => MainScreenPage()
            },
          );
        },
      ),
    );
  }
}
