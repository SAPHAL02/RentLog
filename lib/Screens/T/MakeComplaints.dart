// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rent_log/utils/color_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_log/Screens/Auth/Loading.dart';

class MakeComplaint extends StatefulWidget {
  final String roomId;

  const MakeComplaint({Key? key, required this.roomId}) : super(key: key);

  @override
  _MakeComplaintState createState() => _MakeComplaintState();
}

class _MakeComplaintState extends State<MakeComplaint> {
  final TextEditingController _complaintController = TextEditingController();
  List<String> _complaints = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _complaints = prefs.getStringList('complaints_${widget.roomId}') ?? [];
      _complaints.sort();
      _complaints = _complaints.reversed.toList();
    });
  }

  Future<void> _saveComplaints() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('complaints_${widget.roomId}', _complaints);
  }

  Future<void> _submitComplaint() async {
    String complaintText = _complaintController.text;

    if (complaintText.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text(
              'Please enter a valid complaint.',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _complaints.insert(0, complaintText);
      });

      await _saveComplaints();
      await _saveComplaintsToFirebase();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text(
              'Your complaint has been submitted.',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
      _complaintController.clear();
    }
  }

  Future<void> _saveComplaintsToFirebase() async {
    String roomId = widget.roomId;
    String folderName = roomId;
    String fileName = 'complaints_$roomId.txt';

    String content = '';
    for (int i = 0; i < _complaints.length; i++) {
      String complaint = _complaints[i];
      int complaintNumber = _complaints.length - i;
      content += '$complaintNumber. $complaint\n';
    }

    try {
      firebase_storage.Reference roomsRef =
          firebase_storage.FirebaseStorage.instance.ref().child('rooms');

      firebase_storage.ListResult result = await roomsRef.listAll();

      bool folderExists = false;

      for (var prefix in result.prefixes) {
        if (prefix.name == folderName) {
          folderExists = true;
          break;
        }
      }

      if (!folderExists) {
        print('Folder not found: $folderName');
      }

      firebase_storage.Reference fileRef =
          roomsRef.child('$folderName/$fileName');
      await fileRef.putString(content);
    } catch (e) {
      print('Error saving complaints to Firebase Storage: $e');
    }
  }

  void _viewComplaints() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complaints'),
          content: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _complaints.length,
              itemBuilder: (BuildContext context, int index) {
                String complaint = _complaints[index];
                int complaintNumber = _complaints.length - index;
                return ListTile(
                  title: Text(
                    '$complaintNumber. $complaint',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
        title: const Text(
          'RentLog',
        ),
        backgroundColor: hexStringToColor("05716c"),
      ),
      body: _isLoading
          ? const Loading()
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _complaintController,
                        maxLines: 5,
                        style: const TextStyle(
                          color: Colors.white, // Set the text color
                        ),
                        cursorColor: Colors.white, // Set the cursor color
                        decoration: const InputDecoration(
                          labelText: 'Enter your complaint',
                          labelStyle: TextStyle(
                            color: Colors.white, // Set the label color
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Set the border color
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Set the enabled border color
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Set the focused border color
                          ),
                        ),
                      ),

                      const SizedBox(height: 46.0),
                      ElevatedButton(
                        onPressed: _submitComplaint,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(160, 50),
                        ),
                        child: const Text(
                          'Submit Complaint',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _viewComplaints,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(180, 50),
                        ),
                        child: const Text(
                          'View Complaints',
                          style: TextStyle(fontSize: 18),
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
