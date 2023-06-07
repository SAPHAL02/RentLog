// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rent_log/Screens/O/services_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceProviders extends StatefulWidget {
  final String roomId;

  const ServiceProviders({Key? key, required this.roomId}) : super(key: key);

  @override
  _ServiceProvidersState createState() => _ServiceProvidersState();
}

class _ServiceProvidersState extends State<ServiceProviders> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    askContactsPermission();
  }

  Future askContactsPermission() async {
    final permission = await ContactUtils.getContactPermission();
    print('Contact permission: $permission');
    switch (permission) {
      case PermissionStatus.granted:
        uploadContacts();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text('Please allow to "Upload Contacts"'),
            duration: const Duration(seconds: 3),
          ),
        );
        break;
    }
  }

  Future uploadContacts() async {
  final contacts = (await ContactsService.getContacts(withThumbnails: false)).toList();
  print('Contacts: $contacts');

  // Create a list to store selected contact names and numbers
  final List<String> selectedContactNames = [];
  final List<String> selectedContactNumbers = [];

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
                  itemCount: contacts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final contact = contacts[index];
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
                          // Add or remove the selected contact name from the list
                          if (selectedContactNames.contains(contact.displayName)) {
                            selectedContactNames.remove(contact.displayName);
                            selectedContactNumbers.remove(contact.phones?.first.value);
                          } else {
                            selectedContactNames.add(contact.displayName ?? '');
                            selectedContactNumbers.add(contact.phones?.first.value ?? '');
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
                  onPressed: () {
                    // Print the selected contact names and numbers
                    for (int i = 0; i < selectedContactNames.length; i++) {
                      print('Contact Name: ${selectedContactNames[i]}');
                      print('Contact Number: ${selectedContactNumbers[i]}');
                    }
                    Navigator.of(context).pop();
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

  // Store the selected contacts in shared preferences
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList('selectedContacts', selectedContactNames);

  print('Upload completed.');
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("RentLog"),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              buildButton(context, 'Upload Contacts', askContactsPermission),
              const SizedBox(height: 32),
            ],
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
            backgroundColor: Theme.of(context).primaryColor,
            shape: const StadiumBorder(),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
}
