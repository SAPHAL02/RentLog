// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rent_log/utils/color_util.dart';

class Duedate extends StatefulWidget {
  final String roomId;

  const Duedate({Key? key, required this.roomId}) : super(key: key);

  @override
  _DuedateState createState() => _DuedateState();
}

class _DuedateState extends State<Duedate> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
  }

  void _viewDueDate() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/due_date.txt');

    if (await file.exists()) {
      final dueDate = await file.readAsString();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Due Date'),
            content: Text(dueDate),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Due Date saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveDueDateToFirebase() async {
    String roomId = widget.roomId;
    String folderName = roomId;
    String fileName = 'Duedate_$roomId.txt';

    String content = _dateController.text;

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
      print('Error saving due date to Firebase Storage: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.white,
          hintColor: Colors.blue, // Set the desired accent color
          colorScheme: const ColorScheme.light(
            primary: Colors.blue, // Set the desired primary color
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != _selectedDate) {
    setState(() {
      _selectedDate = picked;
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
    });
  }
}


  Future<void> _saveDueDate() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/due_date.txt');

    await file.writeAsString(_dateController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Due Date saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Due Date',
        ),
        backgroundColor: hexStringToColor("a2a595"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              hexStringToColor("a2a595"),
              hexStringToColor("e0cdbe"),
              hexStringToColor("b4a284"),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                InkWell(
                  onTap: () => _selectDate(context),
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _saveDueDate();
                    _saveDueDateToFirebase();
                  },
                  child: const Text(
                    'Save Due Date',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _viewDueDate,
                  child: const Text(
                    'View Due Date',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
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
