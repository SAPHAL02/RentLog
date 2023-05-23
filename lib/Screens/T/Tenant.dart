// ignore_for_file: unused_local_variable, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

import '../../utils/color_util.dart';

class Tenant extends StatefulWidget {
  const Tenant({Key? key}) : super(key: key);

  @override
  _TenantState createState() => _TenantState();
}

class _TenantState extends State<Tenant> {
  late TextEditingController _roomIdController;

  @override
  void initState() {
    super.initState();
    _roomIdController = TextEditingController();
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  void _enterRoom() {
    String roomId = _roomIdController.text;
    // Perform the necessary actions with the entered room ID
    // ...
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _enterRoom,
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
