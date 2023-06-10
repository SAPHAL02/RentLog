// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_log/Screens/Auth/Loading.dart';
import 'package:rent_log/Screens/Auth/signin_screen.dart';
import 'package:rent_log/reusable/reusable_widget.dart';
import 'package:rent_log/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController =
      TextEditingController();
  bool loading = false;
  var options = [
    'Owner',
    'Tenant',
  ];
  var _currentItemSelected = "Owner";
  var role = "Owner";

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> createUser() async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailTextController.text,
        password: _passwordTextController.text,
      );

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);

      await userDocRef.set({
        'email': _emailTextController.text,
        'role': role,
      });

      showSnackbar(context, 'Account created');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SignInScreen()));
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          setState(() => loading = false);
          showSnackbar(context, 'The email address is already in use.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    
                    hexStringToColor("05716c"),
                    hexStringToColor("031163"),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).size.height * 0.1,
                    20,
                    0,
                  ),
                  child: Column(
                    children: <Widget>[
                      logoWidget("assets/images/house.png"),
                      const SizedBox(
                        height: 20,
                      ),
                      reusableTextField("Enter Email Id", Icons.person_outline,
                          false, _emailTextController),
                      const SizedBox(
                        height: 20,
                      ),
                      reusableTextField("Enter Password", Icons.lock_outlined,
                          true, _passwordTextController),
                      const SizedBox(
                        height: 20,
                      ),
                      reusableTextField(
                        "Confirm Password",
                        Icons.lock_outlined,
                        true,
                        _confirmPasswordTextController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 100.0),
                        child: Row(
                          children: [
                            const Text(
                              "Role : ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            DropdownButton<String>(
                              dropdownColor: const Color.fromARGB(255, 32, 103, 168),
                              isExpanded: false,
                              iconEnabledColor: Colors.white,
                              focusColor: Colors.white,
                              items: options.map((String dropDownStringItem) {
                                return DropdownMenuItem<String>(
                                  value: dropDownStringItem,
                                  child: Text(
                                    dropDownStringItem,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                setState(() {
                                  _currentItemSelected = newValueSelected!;
                                  role = newValueSelected;
                                });
                              },
                              value: _currentItemSelected,
                            ),
                          ],
                        ),
                      ),
                      firebaseUIButton(context, "Sign Up", () {
                      if (_emailTextController.text.isEmpty) {
                        showSnackbar(context, 'Please enter an email address.');
                      } else if (!EmailValidator.validate(_emailTextController.text)) {
                        showSnackbar(context, 'Please enter a valid email address.');
                      } else if (_passwordTextController.text.isEmpty) {
                        showSnackbar(context, 'Please enter a password.');
                      } else if (_confirmPasswordTextController.text.isEmpty) {
                        showSnackbar(context, 'Please confirm the password.');
                      } else if (_passwordTextController.text !=
                          _confirmPasswordTextController.text) {
                        showSnackbar(context, 'Passwords do not match.');
                      } else if (_passwordTextController.text.length < 6) {
                        showSnackbar(
                            context, 'Password should be at least 6 characters.');
                      } else {
                        setState(() => loading = true);
                        createUser();
                      }
                    }),

                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
