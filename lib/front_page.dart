import 'package:authenticationapp/login_page.dart';
import 'package:flutter/material.dart';
 // Import your LogIn screen file

class ToDoListIntro extends StatelessWidget {
  const ToDoListIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color similar to the image
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image Section
              Image.asset(
                'assets/Screenshot 2025-01-17 011604-Photoroom.png', // Replace with your asset image path
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20.0),

              // Title Text
              const Text(
                "TO DO LIST",
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),

              // Subtitle Text
              const Text(
                "FIREBASE",
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 40.0),

              // "Let's Go" Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to LogIn screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 50.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                child: const Text(
                  "Let's Go",
                  style: TextStyle(
                    color: Color(0xFF567DF4), // Same as the background color
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30.0),

              // Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10.0,
                    width: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    height: 10.0,
                    width: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    height: 10.0,
                    width: 10.0,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
