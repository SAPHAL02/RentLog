// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:typed_data';

class ViewComplaint extends StatefulWidget {
  final String roomId;

  const ViewComplaint({Key? key, required this.roomId}) : super(key: key);

  @override
  State<ViewComplaint> createState() => _ViewComplaintState();
}

class _ViewComplaintState extends State<ViewComplaint> {
  bool _folderExists = false;
  String _complaintText = '';

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
        await _fetchComplaintText(prefix, context); // Pass the context here
        break;
      }
    }
  }

  Future<void> _fetchComplaintText(
    firebase_storage.Reference folderReference,
    BuildContext context,
  ) async {
    firebase_storage.Reference fileRef =
        folderReference.child('complaints_${widget.roomId}.txt');

    try {
      firebase_storage.FullMetadata metadata = await fileRef.getMetadata();
      if (metadata.size! > 0) {
        Uint8List? downloadData = await fileRef.getData();
        if (downloadData != null) {
          List<int> content = downloadData.toList();
          String complaintText = String.fromCharCodes(content);
          setState(() {
            _complaintText = complaintText;
          });
          return; // Exit the method if the complaint text is successfully retrieved
        }
      }
    } catch (e) {
      print('Error fetching complaint text: $e');
    }

    // Show Snackbar when file is not found
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No Complaints found'),
        duration: Duration(seconds: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Complaint'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: _folderExists && _complaintText.isNotEmpty
            ? Text(
                _complaintText,
                style: const TextStyle(fontSize: 20),
              )
            : _folderExists
                ? const Icon(
                    Icons.sentiment_satisfied,
                    size: 100,
                  )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
