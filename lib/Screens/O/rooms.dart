import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_log/Screens/Auth/signin_screen.dart';
import 'package:rent_log/Screens/O/roomInfo.dart';
import '../../utils/color_util.dart';
import 'package:uuid/uuid.dart';

class Room extends StatefulWidget {
  const Room({Key? key}) : super(key: key);

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> with AutomaticKeepAliveClientMixin {
  List<String> roomNames = [];
  List<String> roomIds = [];
  List<bool> roomRemovable = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  @override
  void dispose() {
    _saveRoomData();
    super.dispose();
  }

  Future<void> _loadRoomData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      roomNames = prefs.getStringList('roomNames') ?? [];
      roomIds = prefs.getStringList('roomIds') ?? [];
      roomRemovable = List.generate(roomNames.length, (_) => false);
    });
  }

  Future<void> _saveRoomData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('roomNames', roomNames);
    await prefs.setStringList('roomIds', roomIds);
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringToColor("a2a595"),
                hexStringToColor("e0cdbe"),
                hexStringToColor("b4a284"),
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RentLog',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  onPressed: _logout,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.logout, color: Colors.grey),
                  mini: true,
                ),
              ],
            ),
            centerTitle: true,
          ),
        ),
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
                                  builder: (context) => OwnerPage(roomId: roomIds[index]),
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
                                  content: const Text("Are you sure you want to delete this room?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text("DELETE"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          return false;
                        },
                        onDismissed: (DismissDirection direction) {
                          setState(() {
                            roomNames.removeAt(index);
                            roomRemovable.removeAt(index);
                            _saveRoomData(); // Save room data
                          });
                        },
                        background: Container(
                          color: const Color.fromARGB(163, 170, 158, 147),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
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
                                style: const TextStyle(color: Colors.white, fontSize: 20),
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

  void _addRoom() {
        setState(() {
          final uuid = Uuid();
          String newRoomId = uuid.v4(); // Generate a unique room ID
          int newRoomNumber = roomNames.length + 1;
          String newRoomName = "Room $newRoomNumber";
          roomNames.add(newRoomName);
          roomIds.add(newRoomId); // Associate the ID with the room
          roomRemovable.add(false);
          _saveRoomData(); // Save room data
        });
      }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}
