// ignore_for_file: unreachable_switch_default, unnecessary_null_comparison

import 'package:authenticationapp/database.dart';
import 'package:authenticationapp/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      
      // If user cancels the sign-in flow
      if (googleSignInAccount == null) {
        return null;
      }

      // Obtain the auth details
      final GoogleSignInAuthentication googleSignInAuthentication = 
          await googleSignInAccount.authentication;

      // Create credentials
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      // Sign in with Firebase
      UserCredential result = await firebaseAuth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        // Store user details in database
        Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          "id": userDetails.uid
        };

        // Add user to database
        await DatabaseMethods().addUser(userDetails.uid, userInfoMap);
        
        // Only navigate if context is still valid
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home())
          );
        }

        return userDetails;
      }
      return null;
    } catch (e) {
      // Handle specific errors
      if (e is FirebaseAuthException) {
        throw PlatformException(
          code: e.code,
          message: e.message ?? 'An error occurred during Google sign in'
        );
      }
      // Re-throw other errors
      throw e;
    }
  }

  Future<User?> signInWithApple({List<Scope> scopes = const []}) async {
    try {
      final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]
      );

      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!)
          );

          final userCredential = await auth.signInWithCredential(credential);
          final firebaseUser = userCredential.user!;

          // Update user display name if full name scope was requested
          if (scopes.contains(Scope.fullName)) {
            final fullName = appleIdCredential.fullName;
            if (fullName != null &&
                fullName.givenName != null &&
                fullName.familyName != null) {
              final displayName = '${fullName.givenName} ${fullName.familyName}'.trim();
              await firebaseUser.updateDisplayName(displayName);
            }
          }

          // Store user details in database
          if (firebaseUser != null) {
            Map<String, dynamic> userInfoMap = {
              "email": firebaseUser.email,
              "name": firebaseUser.displayName,
              "imgUrl": firebaseUser.photoURL,
              "id": firebaseUser.uid
            };

            await DatabaseMethods().addUser(firebaseUser.uid, userInfoMap);
          }

          return firebaseUser;

        case AuthorizationStatus.error:
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString()
          );

        case AuthorizationStatus.cancelled:
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user'
          );

        default:
          throw UnimplementedError();
      }
    } catch (e) {
      // Re-throw PlatformException
      if (e is PlatformException) {
        throw e;
      }
      // Wrap other errors
      throw PlatformException(
        code: 'ERROR_APPLE_SIGN_IN',
        message: e.toString()
      );
    }
  }
}