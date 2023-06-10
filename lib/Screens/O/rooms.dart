// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_log/Screens/Auth/signin_screen.dart';
import 'package:rent_log/Screens/O/roomInfo.dart';
import '../../utils/color_util.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> with AutomaticKeepAliveClientMixin {
  List<String> roomNames = [];
  List<String> roomIds = [];
  List<bool> roomRemovable = [];

  String getCurrentUserID() {
    User? user = FirebaseAuth.instance.currentUser;
    String userID =
        user?.uid ?? ''; // If the user is null, return an empty string
    return userID;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    String userId = getCurrentUserID();

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;

    if (userData != null &&
        userData.containsKey('roomNames') &&
        userData.containsKey('roomIds')) {
      List<dynamic> names = userData['roomNames'];
      List<dynamic> ids = userData['roomIds'];

      setState(() {
        roomNames = List<String>.from(names);
        roomIds = List<String>.from(ids);
        roomRemovable = List.generate(roomNames.length, (_) => false);
      });
    }
  }

  Future<void> _saveRoomData() async {
    String userId = getCurrentUserID();

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'roomNames': roomNames,
      'roomIds': roomIds,
    });
  }

  Future<void> _addRoom() async {
    final uuid = Uuid();
    String newRoomId = uuid.v4(); // Generate a unique room ID
    int newRoomNumber = roomNames.length + 1;
    String newRoomName = "Room $newRoomNumber";

    setState(() {
      roomNames.add(newRoomName);
      roomIds.add(newRoomId); // Associate the ID with the room
      roomRemovable.add(false);
    });

    String userId = getCurrentUserID(); // Get the current user's ID
    String userEmail = FirebaseAuth.instance.currentUser?.email ??
        ''; // Get the current user's email

    // Store room ID and associated email in Firebase Firestore
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({
      'roomNames': roomNames,
      'roomIds': roomIds,
      'userEmail': userEmail, // Add the userEmail field
    });
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                itemCount: roomNames.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index == roomNames.length) {
                    return InkWell(
                      onTap: _addRoom,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 25, 126, 139),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 50, color: Colors.white),
                            Text(
                              "Add Room",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      onLongPress: () {
                        setState(() {
                          roomRemovable[index] = true;
                        });
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OwnerPage(roomId: roomIds[index]),
                          ),
                        );
                      },
                      child: Dismissible(
                        key: UniqueKey(),
                        confirmDismiss: (DismissDirection direction) async {
                          if (direction == DismissDirection.endToStart) {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Room"),
                                  content: const Text(
                                      "Are you sure you want to delete this room?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          setState(() {
                            roomNames.removeAt(index);
                            roomIds.removeAt(index);
                            roomRemovable.removeAt(index);
                          });
                          _saveRoomData();
                        },
                        background: Container(
                          color: Colors.red,
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          color: const Color.fromARGB(255, 25, 126, 139),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: roomRemovable[index]
                                ? Colors.white
                                : const Color.fromARGB(255, 25, 126, 139),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.home,
                                size: 50,
                                color: Colors.white,
                              ),
                              Text(
                                roomNames[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),

                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
