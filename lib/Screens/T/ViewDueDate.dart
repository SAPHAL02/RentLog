// ignore_for_file: use_build_context_synchronously, empty_catches, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:typed_data';
import 'package:rent_log/utils/color_util.dart';

class ViewDuedate extends StatefulWidget {
  final String roomId;

  const ViewDuedate({Key? key, required this.roomId}) : super(key: key);

  @override
  State<ViewDuedate> createState() => _ViewDuedateState();
}

class _ViewDuedateState extends State<ViewDuedate> {
  bool _folderExists = false;
  String _DuedateText = '';

  @override
  void initState() {
    super.initState();
    _checkFolderExists();
  }

  Future<void> _checkFolderExists() async {
    firebase_storage.Reference roomsRef =
        firebase_storage.FirebaseStorage.instance.ref().child('rooms');

    firebase_storage.ListResult result = await roomsRef.listAll();

    for (var prefix in result.prefixes) {
      if (prefix.name == widget.roomId) {
        setState(() {
          _folderExists = true;
        });
        await _fetchDuedateText(prefix, context); // Pass the context here
        break;
      }
    }
  }

  Future<void> _fetchDuedateText(
    firebase_storage.Reference folderReference,
    BuildContext context,
  ) async {
    firebase_storage.Reference fileRef =
        folderReference.child('Duedate_${widget.roomId}.txt');

    try {
      firebase_storage.FullMetadata metadata = await fileRef.getMetadata();
      if (metadata.size! > 0) {
        Uint8List? downloadData = await fileRef.getData();
        if (downloadData != null) {
          List<int> content = downloadData.toList();
          String DuedateText = String.fromCharCodes(content);
          setState(() {
            _DuedateText = DuedateText;
          });
          return; // Exit the method if the Duedate text is successfully retrieved
        }
      }
    } catch (e) {
      
    }

    // Show Snackbar when file is not found
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Duedate found'),
        duration: Duration(seconds: 10),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Duedate',),
      backgroundColor: hexStringToColor("a2a595"),
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
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(26),
        child: _folderExists && _DuedateText.isNotEmpty
            ? SingleChildScrollView(
                child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 200,
                ),
                child: Text(
                  _DuedateText,
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.black87, // Set the text color to white
                  ),
                ),
              ),
              )
            : _folderExists
                ? const Icon(
                    Icons.sentiment_satisfied,
                    size: 100,
                  )
                : const CircularProgressIndicator(),
      ),
    ),
  );
}

}