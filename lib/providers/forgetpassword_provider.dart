import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

 Future<bool> resetPassword(String email) async {
  email = email.trim().toLowerCase();
  _setLoading(true);
  _setErrorMessage(null);

  try {
    // Fetch all registered emails
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // Check if user exists in database
    if (userQuery.docs.isEmpty) {
      _setErrorMessage("This email is not registered");
      _setLoading(false);
      return false;
    }

    // Send password reset email
    await _auth.sendPasswordResetEmail(email: email);
    print('Password reset email sent'); // Added print statement
    _setLoading(false);
    return true;
  } on FirebaseAuthException catch (e) {
    String errorMessage = "";
    switch (e.code) {
      case "invalid-email":
        errorMessage = "Invalid email address";
        break;
      case "user-not-found":
        errorMessage = "No account found with this email";
        break;
      case "too-many-requests":
        errorMessage = "Too many reset attempts. Try later";
        break;
      default:
        errorMessage = "Reset failed: ${e.code}";
    }
    _setErrorMessage(errorMessage);
    _setLoading(false);
    return false;
  } catch (e) {
    _setErrorMessage("Unexpected error");
    _setLoading(false);
    return false;
  }
}
}