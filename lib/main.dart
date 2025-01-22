// ignore_for_file: prefer_const_constructors

import 'package:authenticationapp/providers/forgetpassword_provider.dart';
import 'package:authenticationapp/providers/homescreenprovider.dart';
import 'package:authenticationapp/screens/frontpage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 // Import DefaultFirebaseOptions correctly

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()), // Ensure NotesProvider is defined
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class DefaultFirebaseOptions {
  static var currentPlatform;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ToDoListIntro(), // Assuming FrontPage is your intended home widget
    );
  }
}
