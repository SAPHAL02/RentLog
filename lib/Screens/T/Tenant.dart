// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:rent_log/Screens/Auth/signin_screen.dart';
import 'package:rent_log/Screens/T/TenantInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/color_util.dart';

class Tenant extends StatefulWidget {
  const Tenant({Key? key}) : super(key: key);

  @override
  _TenantState createState() => _TenantState();
}

class _TenantState extends State<Tenant> {
  late TextEditingController _roomIdController;
  List<String> createdRoomIds = []; // Updated list

  @override
  void initState() {
    super.initState();
    _roomIdController = TextEditingController();
    _loadRoomData(); // Load the room data
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    _saveRoomData(); // Save the room data
    super.dispose();
  }

  Future<void> _loadRoomData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      createdRoomIds = prefs.getStringList('roomIds') ?? []; // Use the 'roomIds' from Room class
    });
  }

  Future<void> _saveRoomData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('roomIds', createdRoomIds); // Save the updated list
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Remove tenant IDs from shared preferences
    // ...

    // Remove stored email and password
    await prefs.remove('email');
    await prefs.remove('password');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  void _onEnterRoomPressed() async {
  String roomId = _roomIdController.text;

  // Fetch the current user's room IDs from Firebase
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId != null) {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('roomIds', arrayContains: roomId)
        .get();

    if (querySnapshot.size > 0) {
      // Room ID exists in at least one document
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TenantInfo(roomId: roomId)),
      );
      return; // Exit the method if the room ID is valid
    }
  }

  


  // Show error dialog if the room ID is invalid
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Invalid Room ID'),
        content: const Text('The entered Room ID is invalid.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Remove the shadow
        backgroundColor: hexStringToColor("a2a595"), // Set the background color of the AppBar
        title: const Text(
          'RentLog',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      body: Container(
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _roomIdController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Room ID',
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _onEnterRoomPressed,
                  child: const Text('Enter Room'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}