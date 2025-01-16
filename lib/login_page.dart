import 'package:authenticationapp/auth.dart';
import 'package:authenticationapp/forget_password.dart';
import 'package:authenticationapp/home.dart';
import 'package:authenticationapp/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";

  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Logout existing user
  Future<void> _logoutCurrentUser() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut(); // Ensures Google account chooser appears
  }

  // User login with email and password
  Future<void> userLogin() async {
    try {
      await _logoutCurrentUser();
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "No User Found for that Email",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Wrong Password Provided by User",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      }
    }
  }

  // Google sign-in
  Future<void> signInWithGoogle() async {
    try {
      await _logoutCurrentUser(); // Logout existing user
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } catch (e) {
      print("Error during Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Google Sign-In Failed",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Image.asset(
            "assets/firebase.png.png",
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
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
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please Enter E-mail' : null,
                  ),
                  SizedBox(height: 30.0),
                  buildInputField(
                    controller: passwordcontroller,
                    hintText: "Password",
                    obscureText: true,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please Enter Password' : null,
                  ),
                  SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () {
                      if (_formkey.currentState!.validate()) {
                        setState(() {
                          email = mailcontroller.text;
                          password = passwordcontroller.text;
                        });
                        userLogin();
                      }
                    },
                    child: buildSignInButton("Sign In"),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.0),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ForgotPassword()));
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
            onTap: signInWithGoogle,
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
              Text("Don't have an account?",
                  style: TextStyle(color: Color(0xFF8c8e98), fontSize: 18.0)),
              SizedBox(width: 5.0),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: Text(
                  "SignUp",
                  style: TextStyle(color: Color(0xFF273671), fontSize: 20.0),
                ),
              ),
            ],
          )
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

  Widget buildSignInButton(String text) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
      decoration: BoxDecoration(
        color: Color(0xFF273671),
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
