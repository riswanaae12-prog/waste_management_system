import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/bin_provider.dart';
import 'providers/issue_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  // Ensure Flutter is ready before we do anything else.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create a Future to represent the Firebase initialization process.
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BinProvider()),
        ChangeNotifierProvider(create: (_) => IssueProvider()),
      ],
      child: MaterialApp(
        title: 'Neatify', // Changed title
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        // Use a FutureBuilder to show a loading screen while Firebase initializes.
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            // If there's an error, show a generic error screen.
            if (snapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text("Something went wrong with Firebase. Please restart."),
                ),
              );
            }

            // Once initialization is complete, show the main app logic.
            if (snapshot.connectionState == ConnectionState.done) {
              return Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.isLoading) {
                    return const SplashScreen(); // Show splash while auth state loads
                  }
                  return authProvider.isAuthenticated
                      ? const HomeScreen()
                      : const LoginScreen();
                },
              );
            }

            // While initializing, show the splash screen.
            return const SplashScreen();
          },
        ),
      ),
    );
  }
}
