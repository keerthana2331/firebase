import 'package:authenticationapp/front_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:authenticationapp/home.dart';
import 'package:authenticationapp/signup.dart';
import 'package:authenticationapp/forget_password.dart';
 // Updated import for TodoIntroScreen

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
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackBar(context, "No User Found for that Email");
      } else if (e.code == 'wrong-password') {
        _showSnackBar(context, "Wrong Password Provided by User");
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.orangeAccent,
      content: Text(message, style: TextStyle(fontSize: 18.0)),
    ));
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
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } catch (e) {
      print("Error during Google Sign-In: $e");
      _showSnackBar(context, "Google Sign-In Failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.asset(
                      "assets/firebase.png.png", // Updated path for image
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 30.0,
                      left: 10.0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ToDoListIntro()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        buildInputField(
                          controller: mailcontroller,
                          hintText: "Email",
                          validator: (value) => value == null || value.isEmpty ? 'Please Enter E-mail' : null,
                        ),
                        SizedBox(height: 30.0),
                        buildInputField(
                          controller: passwordcontroller,
                          hintText: "Password",
                          obscureText: true,
                          validator: (value) => value == null || value.isEmpty ? 'Please Enter Password' : null,
                        ),
                        SizedBox(height: 30.0),
                        GestureDetector(
                          onTap: () {
                            if (_formkey.currentState!.validate()) {
                              userLogin(context, mailcontroller.text, passwordcontroller.text);
                            }
                          },
                          child: buildSignInButton("Sign In", context),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF8c8e98), fontSize: 18.0),
                  ),
                ),
                SizedBox(height: 40.0),
                Text(
                  "or LogIn with",
                  style: TextStyle(color: Color(0xFF273671), fontSize: 22.0),
                ),
                SizedBox(height: 30.0),
                GestureDetector(
                  onTap: () {
                    signInWithGoogle(context);
                  },
                  child: Image.asset(
                    "assets/google.png.png",
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: Color(0xFF8c8e98), fontSize: 18.0)),
                    SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text("SignUp", style: TextStyle(color: Color(0xFF273671), fontSize: 20.0)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 20.0,
            right: 20.0,
            child: GestureDetector(
              onTap: () {
                print("Profile tapped"); // Add navigation or profile action here
              },
              child: CircleAvatar(
                radius: 25.0,
                backgroundImage: AssetImage("assets/avatar.png.png"), // Updated path for image
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFFb2b7bf), fontSize: 18.0),
        ),
      ),
    );
  }

  Widget buildSignInButton(String text, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 22.0),
        ),
      ),
    );
  }
}
