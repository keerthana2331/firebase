// forgot_password_provider.dart
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
      // Check if email exists
      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      
      if (signInMethods.isEmpty) {
        _setErrorMessage("No account exists with this email. Please check the email or create a new account.");
        _setLoading(false);
        return false;
      }

      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;

    } on FirebaseAuthException catch (e) {
      String errorMessage = "";
      switch (e.code) {
        case "invalid-email":
          errorMessage = "The email address is invalid.";
          break;
        case "user-not-found":
          errorMessage = "No user found with this email address.";
          break;
        case "too-many-requests":
          errorMessage = "Too many requests. Please try again later.";
          break;
        default:
          errorMessage = "Error: ${e.code} - Please try again.";
      }
      _setErrorMessage(errorMessage);
      _setLoading(false);
      return false;

    } catch (e) {
      _setErrorMessage("An unexpected error occurred. Please try again.");
      _setLoading(false);
      return false;
    }
  }
}