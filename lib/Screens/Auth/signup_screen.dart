import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_log/Screens/Auth/signin_screen.dart';
import 'package:rent_log/reusable/reusable_widget.dart';
import 'package:rent_log/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  var options = [
    'Owner',
    'Tenant',
  ];
  var _currentItemSelected = "Owner";
  var role = "Owner";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                hexStringToColor("a2a595"),
                hexStringToColor("e0cdbe"),
                hexStringToColor("b4a284")
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery
                  .of(context)
                  .size
                  .height * 0.1, 20,0), child: Column(children: <Widget>[
                  logoWidget("assets/images/house.png"),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter UserName", Icons.person_outline, false,_userNameTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Email Id", Icons.person_outline, false,
                        _emailTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    reusableTextField("Enter Password", Icons.lock_outlined, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:100.0),
                      child: Row(
                        children: [
                          const Text(
                            "Role : ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          DropdownButton<String>(
                            dropdownColor: Colors.white,
                            isExpanded: false,
                            iconEnabledColor: Colors.white,
                            focusColor: Colors.white,
                            items: options.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(
                                  dropDownStringItem,
                                  style: const TextStyle(
                                    color: Colors.black54,
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
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                          .then((value)  {
                            
                            // Create a new document reference for the user in Firestore
                            final userDocRef = FirebaseFirestore.instance.collection('users').doc(value.user!.uid);

                            // Update the user document with the selected role
                            userDocRef.set({
                              'email': _emailTextController.text,
                              'role': role,
                            }).then((_) {

                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const SignInScreen()));
                                    }).onError((error, stackTrace) {
                                    });
                                  });
                    },
                ),
              ])),
    ))
    );
}
}