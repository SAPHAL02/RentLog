import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_log/Screens/Auth/Loading.dart';
import 'package:rent_log/Screens/reset_password.dart';
import 'package:rent_log/reusable/reusable_widget.dart';
import 'package:rent_log/Screens/Auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:rent_log/utils/color_util.dart';
import 'package:rent_log/Screens/O/rooms.dart';
import 'package:rent_log/Screens/T/Tenant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    checkCredentials();
  }

  Future<void> checkCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (email != null && password != null) {
      signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    hexStringToColor("a2a595"),
                    hexStringToColor("e0cdbe"),
                    hexStringToColor("b4a284"),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).size.height * 0.2,
                    20,
                    0,
                  ),
                  child: Column(
                    children: <Widget>[
                      logoWidget("assets/images/house.png"),
                      const SizedBox(
                        height: 30,
                      ),
                      reusableTextField(
                        "Enter email",
                        Icons.person_outline,
                        false,
                        _emailTextController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      reusableTextField(
                        "Enter password",
                        Icons.lock_outline,
                        true,
                        _passwordTextController,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      forgetPassword(context),
                      firebaseUIButton(
                        context,
                        "Sign In",
                        () {
                          String email = _emailTextController.text.trim();
                          String password = _passwordTextController.text;

                          if (email.isEmpty || password.isEmpty) {
                            showSnackbar(context, 'Please enter both email and password');
                            return;
                          }

                          signIn(email, password);
                        },
                      ),
                      signUpOption(),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResetPassword())),
      ),
    );
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "Owner") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Room(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Tenant(),
            ),
          );
        }
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      setState(() {
        loading = true;
      });
      showSnackbar(context, 'Sign In Successful');
      saveCredentials(email, password);
      route();
    } catch (error) {
      showSnackbar(context, 'Invalid email or password');
    }
  }

  Future<void> saveCredentials(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
  }
}
