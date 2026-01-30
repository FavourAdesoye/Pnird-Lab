// ignore_for_file: prefer_const_constructors
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:pnirdlab/main_screen.dart';
import 'package:pnirdlab/pages/loginpages/staff_signup.dart';
import 'package:pnirdlab/pages/loginpages/staff_login.dart';
import 'package:pnirdlab/pages/loginpages/community_login.dart';
import 'package:pnirdlab/pages/loginpages/community_signup.dart';
import 'package:pnirdlab/pages/loginpages/choose_account_type.dart';
import 'package:pnirdlab/pages/loginpages/email_verification_page.dart';
import 'package:pnirdlab/pages/loginpages/email_test_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pnirdlab/services/auth.dart';
import 'package:pnirdlab/providers/theme_provider.dart';
import 'package:pnirdlab/theme/app_theme.dart';
import 'package:pnirdlab/firebase_options.dart';


void main() async {
  // Force print immediately
  debugPrint("🚀🚀🚀 APP STARTING NOW 🚀🚀🚀");
  print("🚀 App startup begin");
  
  final startTime = DateTime.now();
  
  try {
    //Ensure all bindings are initialized before running the app
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    print("⏱️  Bindings initialized: ${DateTime.now().difference(startTime).inMilliseconds}ms");
    
    // Keep splash screen while loading resources
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    
    if (!kIsWeb) {
      try {
        await dotenv.load(fileName: ".env");
        print("✅ Environment variables loaded successfully at ${DateTime.now().difference(startTime).inMilliseconds}ms");
      } catch (e) {
        // .env file is optional, app will use default values
        print("⚠️  No .env file found, using default configuration");
      }
    } else {
      print("⏭️  Skipping environment variable loading for web build");
    }
    
    // Initialize Firebase (CRITICAL - app cannot function without it)
    print("🔥 Initializing Firebase...");
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          print("✅ Firebase initialized successfully at ${DateTime.now().difference(startTime).inMilliseconds}ms");
        } catch (initError) {
          // Handle duplicate-app error gracefully (can happen if initialized by native code)
          if (initError.toString().contains('duplicate-app') || 
              initError.toString().contains('[core/duplicate-app]')) {
            print("✅ Firebase already initialized by native code, continuing...");
          } else {
            // Re-throw if it's a different error
            throw initError;
          }
        }
      } else {
        print("✅ Firebase already initialized, skipping...");
      }
    } catch (e) {
      // Only treat non-duplicate errors as critical failures
      if (e.toString().contains('duplicate-app') || 
          e.toString().contains('[core/duplicate-app]')) {
        print("✅ Firebase already initialized (duplicate-app caught), continuing...");
      } else {
        // Firebase initialization is CRITICAL - if it fails, app cannot function
        print("❌ CRITICAL: Firebase initialization FAILED: $e");
        print("❌ Stack trace:");
        print(e);
        FlutterNativeSplash.remove();
        runApp(ErrorApp(
          error: "Firebase initialization failed.\n\nError: $e\n\nPlease check your Firebase configuration and try again.",
        ));
        return; // Exit main function - app cannot continue without Firebase
      }
    }
    
    // Verify Firebase is actually initialized
    if (Firebase.apps.isEmpty) {
      print("❌ CRITICAL: Firebase apps list is empty after initialization attempt");
      FlutterNativeSplash.remove();
      runApp(ErrorApp(
        error: "Firebase initialization failed: No Firebase apps found.\n\nPlease check your Firebase configuration.",
      ));
      return;
    }
    print("✅ Firebase verification: ${Firebase.apps.length} app(s) initialized");
    
    // Simulating an authentication check
    print("🔐 Checking login state...");
    bool isLoggedIn = await checkUserLoggedIn();
    print("✅ Login check complete at ${DateTime.now().difference(startTime).inMilliseconds}ms - User logged in: $isLoggedIn");
    
    //Remove splash screen before running the app
    FlutterNativeSplash.remove();
    print("✅ Splash screen removed at ${DateTime.now().difference(startTime).inMilliseconds}ms");
    
    //Run the app
    print("🏃 Running app at ${DateTime.now().difference(startTime).inMilliseconds}ms");
    runApp(MyApp(isLoggedIn: isLoggedIn));
    
    final totalTime = DateTime.now().difference(startTime).inMilliseconds;
    print("🎉 Total startup time: ${totalTime}ms");
  } catch (e, stackTrace) {
    print("❌ Fatal error during startup: $e");
    print("Stack trace: $stackTrace");
    FlutterNativeSplash.remove();
    runApp(ErrorApp(error: e.toString()));
  }
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
              '/community_signup': (context) => CommunitySignUpPage(),
              '/community_login': (context) => CommunityLoginPage(),
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

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'App Startup Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
