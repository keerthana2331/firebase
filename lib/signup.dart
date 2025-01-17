import 'package:authenticationapp/front_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:authenticationapp/home.dart';
import 'package:authenticationapp/login_page.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _logoutCurrentUser() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    try {
      await _logoutCurrentUser();
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(context, CustomPageRoute(child: Home()));
      }
    } catch (e) {
      _showErrorSnackBar(context, 'google-sign-up-failed');
    }
  }

  Future<void> userSignUp(BuildContext context) async {
    try {
      await _logoutCurrentUser();
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(context, CustomPageRoute(child: Home()));
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, e.code);
    }
  }

  void _showErrorSnackBar(BuildContext context, String code) {
    String message = "An error occurred";
    if (code == 'email-already-in-use') {
      message = "Email is already registered";
    } else if (code == 'weak-password') {
      message = "Password is too weak";
    } else if (code == 'google-sign-up-failed') {
      message = "Google sign up failed";
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        backgroundColor: Colors.deepOrange.shade400,
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow.shade100,
              Colors.orange.shade100,
              Colors.deepOrange.shade100,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.deepOrange.shade400,
                          ),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            CustomPageRoute(child: LogIn()),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Profile Picture and Title
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage: const AssetImage('assets/avatar.png.png'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.orange.shade700,
                                    Colors.deepOrange.shade900,
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  "Create Account",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Sign Up Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _buildInputField(
                                  controller: nameController,
                                  hintText: "Name",
                                  icon: Icons.person_rounded,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Email Field
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1400),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _buildInputField(
                                  controller: emailController,
                                  hintText: "Email",
                                  icon: Icons.email_rounded,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1600),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _buildInputField(
                                  controller: passwordController,
                                  hintText: "Password",
                                  icon: Icons.lock_rounded,
                                  obscureText: true,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Sign Up Button
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1800),
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: _buildSignUpButton(context),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Google Sign Up
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 2000),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Column(
                                children: [
                                  Text(
                                    "Or sign up with",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () => signUpWithGoogle(context),
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        "assets/google.png.png",
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Login Link
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 2200),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacement(
                                      context,
                                      CustomPageRoute(child: LogIn()),
                                    ),
                                    child: Text(
                                      "Login",
                                      style: GoogleFonts.poppins(
                                        color: Colors.deepOrange.shade400,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          if (hintText == "Email" && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          if (hintText == "Password" && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.deepOrange.shade400,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade400,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            userSignUp(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "Sign Up",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}