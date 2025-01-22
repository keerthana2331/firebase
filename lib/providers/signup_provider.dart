import 'package:authenticationapp/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpState extends ChangeNotifier {
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getters
  bool get isLoading => _isLoading;
  String? get nameError => _nameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  // Validate name
  void validateName(String value) {
    if (value.isEmpty) {
      _nameError = 'Please enter your name';
    } else if (value.length < 2) {
      _nameError = 'Name must be at least 2 characters long';
    } else {
      _nameError = null;
    }
    notifyListeners();
  }

  // Validate email
  void validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (value.isEmpty) {
      _emailError = 'Please enter your email';
    } else if (!emailRegex.hasMatch(value)) {
      _emailError = 'Please enter a valid email address';
    } else {
      _emailError = null;
    }
    notifyListeners();
  }

  // Validate password
  void validatePassword(String value) {
    final passwordRegex = RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]+$');
    if (value.isEmpty) {
      _passwordError = 'Please enter your password';
    } else if (value.length < 8) {
      _passwordError = 'Password must be at least 8 characters long';
    } else if (!passwordRegex.hasMatch(value)) {
      _passwordError =
          'Password must include uppercase, lowercase, number, and special character';
    } else {
      _passwordError = null;
    }
    notifyListeners();
  }

  // Sign up with email and password
  Future<void> signUpUser(
      String name, String email, String password, BuildContext context) async {
    if (_emailError != null || _passwordError != null || _nameError != null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Create user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Account created successfully!',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already registered';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            errorMessage,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'An unexpected error occurred: $e',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up with Google
  Future<void> signUpWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign out any existing user
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();

      // Begin Google sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with Google credential
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Check if the user already exists in Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        // If the user doesn't exist, create a new record
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': googleUser.displayName,
            'email': googleUser.email,
            'createdAt': DateTime.now(),
            'signInMethod': 'google',
          });
        }

        // Navigate to the Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              'Google sign-in was canceled.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Google sign-up failed: $e',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset all errors
  void resetErrors() {
    _nameError = null;
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }
}
