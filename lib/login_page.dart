import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:authenticationapp/home.dart';
import 'package:authenticationapp/signup.dart';
import 'package:authenticationapp/forget_password.dart';
import 'package:authenticationapp/front_page.dart';

// Reuse the same CustomPageRoute for consistent transitions
class LogIn extends StatelessWidget {
  LogIn({super.key});

  final TextEditingController mailcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _logoutCurrentUser() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> userLogin(BuildContext context, String email, String password) async {
    try {
      await _logoutCurrentUser();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      Navigator.push(context, CustomPageRoute(child: Home()));
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(context, e.code);
    }
  }

  void _showErrorSnackBar(BuildContext context, String code) {
    String message = "An error occurred";
    if (code == 'user-not-found') {
      message = "No User Found for that Email";
    } else if (code == 'wrong-password') {
      message = "Wrong Password Provided";
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

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _logoutCurrentUser();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.push(context, CustomPageRoute(child: Home()));
    } catch (e) {
      _showErrorSnackBar(context, "google-sign-in-failed");
    }
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
              padding: const EdgeInsets.all(40.0),
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
                            CustomPageRoute(child: ToDoListIntro()),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Welcome Text
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(50 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: Text(
                            "Welcome Back!",
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Login Form
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _buildInputField(
                                  controller: mailcontroller,
                                  hintText: "Email",
                                  icon: Icons.email_rounded,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please Enter Email'
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1400),
                          builder: (context, double value, child) {
                            return Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: _buildInputField(
                                  controller: passwordcontroller,
                                  hintText: "Password",
                                  icon: Icons.lock_rounded,
                                  obscureText: true,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please Enter Password'
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1600),
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: _buildLoginButton(context),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Forgot Password
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1800),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  CustomPageRoute(child: ForgotPassword()),
                                ),
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepOrange.shade400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Google Sign In
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 2000),
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Column(
                                children: [
                                  Text(
                                    "Or continue with",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () => signInWithGoogle(context),
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

                        // Sign Up Link
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
                                    "Don't have an account? ",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      CustomPageRoute(child: SignUp()),
                                    ),
                                    child: Text(
                                      "Sign Up",
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
    String? Function(String?)? validator,
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
        validator: validator,
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

  Widget _buildLoginButton(BuildContext context) {
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
          if (_formkey.currentState!.validate()) {
            userLogin(context, mailcontroller.text, passwordcontroller.text);
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
          "Login",
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