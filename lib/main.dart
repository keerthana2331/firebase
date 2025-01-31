// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'package:authenticationapp/providers/forgetpassword_provider.dart';
import 'package:authenticationapp/providers/homescreenprovider.dart';
import 'package:authenticationapp/screens/frontpage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
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
      home: ToDoListIntro(),
    );
  }
}