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
    super.dispose();
  }

  Future<void> _loadRoomData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedRoomIds = prefs.getStringList('roomIds') ?? [];
    if (storedRoomIds.isNotEmpty) {
      setState(() {
        print("hello");
        createdRoomIds = storedRoomIds;
        _roomIdController.text =
            storedRoomIds.last; // Autofill with the last stored room ID
        print(_roomIdController.text);
      });
    }
  }

  Future<void> _confirmExit() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              'Confirm Exit',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: const Text(
              'Are you sure you want to exit?',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          backgroundColor: hexStringToColor("05716c"), // Set background color
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white, // Set button text color
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                await prefs.remove('email');
                await prefs.remove('password');

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white, // Set button text color
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  void _onEnterRoomPressed() async {
    String roomId = _roomIdController.text;

    // Fetch the current user's room IDs from Firebase
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('roomIds', arrayContains: roomId)
              .get();

      if (querySnapshot.size > 0) {
        // Room ID exists in at least one document
        await _storeRoomId(roomId); // Store the room ID in shared preferences
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

  Future<void> _storeRoomId(String roomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedRoomIds = prefs.getStringList('roomIds') ?? [];
    if (!storedRoomIds.contains(roomId)) {
      storedRoomIds.add(roomId);
      await prefs.setStringList('roomIds', storedRoomIds);
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text('RentLog'),
            const Spacer(),
            TextButton(
              onPressed: _confirmExit,
              child: const Text(
                '\t\t\tExit\nRoom',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: hexStringToColor("05716c"),
      ),
      extendBodyBehindAppBar: true, // Extend the body behind the AppBar
      body: Container(
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                    controller: _roomIdController,
                    style: const TextStyle(
                      color: Colors.white, // Set the text color of the input
                    ),
                    cursorColor: Colors.white, // Set the cursor color of the input
                    decoration: const InputDecoration(
                      labelText: 'Enter Room ID',
                      labelStyle: TextStyle(
                        color: Colors.white, // Set the label color
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Set the input border color
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white), // Set the focused input border color
                      ),
                    ),
                  ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _onEnterRoomPressed,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // Set the button background color
                  ),
                  child: const Text(
                    'Enter Room',
                    style: TextStyle(
                      color: Colors.black, // Set the button text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
