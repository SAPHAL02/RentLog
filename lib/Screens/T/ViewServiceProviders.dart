import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:typed_data';
import 'package:flutter/services.dart'; // Import the services library for clipboard functionality

import 'package:rent_log/utils/color_util.dart';

class ViewServiceProviders extends StatefulWidget {
  final String roomId;

  const ViewServiceProviders({Key? key, required this.roomId}) : super(key: key);

  @override
  State<ViewServiceProviders> createState() => _ViewServiceProvidersState();
}

class _ViewServiceProvidersState extends State<ViewServiceProviders> {
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
        folderReference.child('Service_${widget.roomId}.txt');

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
      print('Error fetching Service provider text: $e');
    }

    // Show Snackbar when file is not found
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No provider found'),
        duration: Duration(seconds: 10),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Providers',
        ),
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
          child: _folderExists && _complaintText.isNotEmpty
              ? SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height - 200,
                    ),
                    child: GestureDetector(
                      // Wrap the Text widget with GestureDetector
                      onLongPress: () {
                        _copyToClipboard(_complaintText); // Call the copy function
                      },
                      child: SelectableText(
                        _complaintText,
                        style: const TextStyle(fontSize: 20),
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
