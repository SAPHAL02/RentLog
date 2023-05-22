import 'package:flutter/material.dart';
import 'package:rent_log/Screens/Auth/signin_screen.dart';
import 'package:rent_log/Screens/O/roomInfo.dart';
import '../../utils/color_util.dart';



class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> with AutomaticKeepAliveClientMixin {
  List<String> roomNames = [];

  @override
  bool get wantKeepAlive => true;


  @override
  void dispose() {
    // Save the state here
    // Store the `roomNames` list to persistent storage or any desired method
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
      title: const Text(
        'RentLog',
        style: TextStyle(
          fontSize: 24, // Set the font size to 24
          fontWeight: FontWeight.bold, // Apply bold font weight
          letterSpacing: 1.5, // Adjust letter spacing
          color: Colors.white, // Set the text color
        ),
      ),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      ),
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
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                itemCount: roomNames.length + 1, // Add 1 for "Add Room" button
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index == roomNames.length) {
                    // Last item, display "Add Room" button
                    return InkWell(
                      onTap: _addRoom,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 158, 149, 132),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 50, color: Colors.white),
                            Text(
                              "Add Room",
                              style: TextStyle(color: Colors.white, fontSize: 30),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Display existing room
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OwnerPage(roomId: '',)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: const Color.fromARGB(255, 158, 149, 132),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.home, size: 50, color: Colors.white),
                            Text(
                              roomNames[index],
                              style: const TextStyle(color: Colors.white, fontSize: 30),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _logout();
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.logout, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addRoom() {
    setState(() {
      // Generate a new room name and add it to the list
      int newRoomNumber = roomNames.length + 1;
      String newRoomName = "Room $newRoomNumber";
      roomNames.add(newRoomName);
    });
  }

  void _logout() {
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}
