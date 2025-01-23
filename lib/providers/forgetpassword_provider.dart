import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

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
      // Verbose logging for diagnostics
      developer.log('Attempting password reset for: $email', 
        name: 'PasswordResetProvider');

      List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);

      // Detailed sign-in method logging
      developer.log('Sign-in methods for $email: $signInMethods', 
        name: 'PasswordResetProvider');

      if (signInMethods.isEmpty) {
        _setErrorMessage("No account found");
        _setLoading(false);
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email);
      
      developer.log('Password reset email sent successfully', 
        name: 'PasswordResetProvider');

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      // Comprehensive error logging
      developer.log('FirebaseAuthException: ${e.code} - ${e.message}', 
        name: 'PasswordResetProvider', 
        error: e);

      String errorMessage = _getErrorMessage(e.code);
      _setErrorMessage(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      // General error logging
      developer.log('Unexpected error during reset', 
        name: 'PasswordResetProvider', 
        error: e);

      _setErrorMessage("Unexpected error");
      _setLoading(false);
      return false;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case "invalid-email":
        return "Invalid email address";
      case "user-not-found":
        return "No user found";
      case "too-many-requests":
        return "Too many reset attempts";
      case "network-request-failed":
        return "Network error. Check connection";
      default:
        return "Reset failed: $code";
    }
  }
}