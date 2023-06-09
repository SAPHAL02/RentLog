// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rent_log/utils/color_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_log/Screens/Auth/Loading.dart';

class ServiceProviders extends StatefulWidget {
  final String roomId;

  const ServiceProviders({Key? key, required this.roomId}) : super(key: key);

  @override
  _ServiceProvidersState createState() => _ServiceProvidersState();
}

class _ServiceProvidersState extends State<ServiceProviders> {
  List<Contact>? contacts;
  List<String> selectedContactNames = [];
  List<String> selectedContactNumbers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

 Future<void> askContactsPermission() async {
  PermissionStatus permissionStatus = await Permission.contacts.status;

  while (!permissionStatus.isGranted) {
    if (permissionStatus.isPermanentlyDenied) {
      // If the user has previously denied the permission permanently,
      // show a dialog explaining why the permission is necessary and redirect the user to app settings.
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Please grant access to contacts in app settings to proceed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('App Settings'),
            ),
          ],
        ),
      );
      break;
    }

    // Request the permission if not granted
    permissionStatus = await Permission.contacts.request();
  }

  if (permissionStatus.isGranted) {
    // Permission granted, proceed with uploading contacts
    uploadContacts();
  } else {
    // Permission not granted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: const Text('Please allow access to contacts'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}


 Future<void> uploadContacts() async {
  contacts = (await ContactsService.getContacts(withThumbnails: false)).toList();
  
  // Delay the showDialog to allow the current build cycle to complete
  await Future.delayed(Duration.zero);

  // Display all contacts and allow selection
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FractionallySizedBox(
            widthFactor: 1.2, // Adjust the width as needed
            heightFactor: 1, // Adjust the height as needed
            child: AlertDialog(
              title: const Text('Select Contacts'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: contacts!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final contact = contacts![index];
                    return ListTile(
                      title: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: selectedContactNames.contains(contact.displayName)
                                ? Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                                : null,
                          ),
                          SizedBox(width: 16),
                          Text(contact.displayName ?? ''),
                        ],
                      ),
                      onTap: () {
                          setState(() {
                            final displayName = contact.displayName ?? '';
                            final phoneNumber = contact.phones?.first.value ?? '';

                            // Check if the contact is already selected using display name
                            final contactIndex = selectedContactNames.indexOf(displayName);

                            if (contactIndex != -1) {
                              // Contact is already selected, remove it
                              selectedContactNames.removeAt(contactIndex);
                              selectedContactNumbers.removeAt(contactIndex);
                            } else {
                              // Contact is not selected, add it
                              selectedContactNames.add(displayName);
                              selectedContactNumbers.add(phoneNumber);
                            }
                          });
                        },

                      selected: selectedContactNames.contains(contact.displayName),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    
                    Navigator.of(context).pop();

                    // Store the selected contacts in shared preferences
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setStringList('selectedContacts', selectedContactNames);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selected contacts saved successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  Future<void> viewProviders() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final selectedContacts = prefs.getStringList('selectedContacts');

    if (selectedContacts != null && selectedContacts.isNotEmpty) {
      final content = selectedContacts.map((name) {
        final index = selectedContactNames.indexOf(name);
        final number = selectedContactNumbers[index];
        return '$name: $number';
      }).join('\n');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Selected Providers'),
            content: Text(content),
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
          content: Text('No selected providers found'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to view providers'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


Future<void> _saveDueDateToFirebase() async {
  
  setState(() {
      _isLoading = true;
    });


  String roomId = widget.roomId;
  String folderName = roomId;
  String fileName = 'Service_$roomId.txt';

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
      await roomsRef.child(folderName).putString('');
    }

    // Create the content of the file with contact names and numbers
    String content = '';
    for (int i = 0; i < selectedContactNames.length; i++) {
      content += 'Provider ${i + 1}:\n';
      content += 'Name: ${selectedContactNames[i]}\n';
      content += 'Number: ${selectedContactNumbers[i]}\n\n';
    }

    firebase_storage.Reference fileRef = roomsRef.child('$folderName/$fileName');
    await fileRef.putString(content);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Services saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to save services'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  setState(() {
      _isLoading = false;
    });
}






 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service Providers'),
        backgroundColor: hexStringToColor("a2a595"),
      ),
      body: _isLoading
          ? const Loading()
          : Container(
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
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildButton(context, 'Upload Contacts', askContactsPermission),
                      const SizedBox(height: 32),
                      buildButton(context, 'Save Providers', _saveDueDateToFirebase),
                      const SizedBox(height: 32),
                      buildButton(context, 'View Providers', viewProviders),
                    ],
                  ),
                ),
              ),
            ),
          );
        }


  Widget buildButton(BuildContext context, String text, VoidCallback onPressed) => SizedBox(
      height: 50,
      width: 170,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );

}


Future<Directory> getApplicationDocumentsDirectory() async {
  return await getApplicationDocumentsDirectory();
}
