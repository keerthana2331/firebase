// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthProvider with ChangeNotifier {
//   bool _isLoggedIn = false;

//   bool get isLoggedIn => _isLoggedIn;

//   AuthProvider() {
//     _loadAuthState();
//   }

//   Future<void> _loadAuthState() async {
//     final prefs = await SharedPreferences.getInstance();
//     _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     notifyListeners();
//   }

//   Future<void> login() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', true);
//     _isLoggedIn = true;
//     notifyListeners();
//   }

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', false);
//     _isLoggedIn = false;
//     notifyListeners();
//   }
// }