// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, depend_on_referenced_packages, empty_catches
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rent_log/Screens/Auth/signin_screen.dart';
import 'package:rent_log/Screens/T/MakeComplaints.dart';
import 'package:rent_log/Screens/T/ViewDueDate.dart';
import 'package:rent_log/Screens/T/ViewServiceProviders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/color_util.dart';


class TenantInfo extends StatefulWidget {
  final String roomId;

  const TenantInfo({Key? key, required this.roomId}) : super(key: key);

  @override
  _TenantInfoState createState() => _TenantInfoState();
}

class _TenantInfoState extends State<TenantInfo> {
  String? pdfFilePath; // Variable to hold the PDF file path
  Stream<firebase_storage.ListResult>? stream; // Stream for listening to changes in the folder
  String alertContent = '';
  bool hasNewNotification = false;



  void showBill() async {
  bool doesFolderExist = await _checkFolderExistence();

  if (doesFolderExist) {
    String? filePath = await _findPDFFilePath();

    if (filePath != null) {
      setState(() {
        pdfFilePath = filePath; // Store the PDF file path in the local variable
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Bill'),
              backgroundColor: hexStringToColor("a2a595"), // Set AppBar color
            ),
            body: Container(
              padding: const EdgeInsets.all(16.0),
              child: PDFView(
                filePath: pdfFilePath,
                fitEachPage: true, // Fit each page of the PDF
                defaultPage: 0, // Set the default page to display
                pageFling: true, // Enable page fling
              ),
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('The Bill does not exist.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('No Bill is generated.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}




void _navigateToDuedatePage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewDuedate(roomId: widget.roomId),
    ),
  );
}

void _navigateToServicePage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewServiceProviders(roomId: widget.roomId),
    ),
  );
}






Future<void> _confirmExit() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Exit'),
        content: const Text('Are you sure you want to exit the room?'),
        backgroundColor: hexStringToColor("DAE9BE"), // Set background color
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white, // Set button text color
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              await prefs.remove('email');
              await prefs.remove('password');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.white, // Set button text color
            ),
            child: const Text('Exit'),
          ),
        ],
      );
    },
  );
}



  Future<bool> _checkFolderExistence() async {
    String folderPath = 'rooms/${widget.roomId}';
    firebase_storage.Reference folderRef =
        firebase_storage.FirebaseStorage.instance.ref().child(folderPath);
    firebase_storage.ListResult listResult = await folderRef.list();
    
    return listResult.items.isNotEmpty;
  }

  Future<String?> _findPDFFilePath() async {
  String folderPath = 'rooms/${widget.roomId}';
  firebase_storage.Reference folderRef =
      firebase_storage.FirebaseStorage.instance.ref().child(folderPath);

  firebase_storage.ListResult listResult = await folderRef.listAll();

  for (var item in listResult.items) {
    if (item.name == 'bill_${widget.roomId}.pdf') {
      String filePath = await _downloadPDF(item);
      return filePath;
    }
  }

  return null;
}


  Future<String> _downloadPDF(firebase_storage.Reference storageRef) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  String fileName = 'bill_${widget.roomId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  String filePath = '$appDocPath/$fileName';

  File file = File(filePath);
  if (file.existsSync()) {
    // If the file already exists, return the file path
    return filePath;
  }

  await storageRef.writeToFile(file);

  return filePath;
}

  Stream<firebase_storage.ListResult> _listenForChanges() {
    String folderPath = 'rooms/${widget.roomId}';
    firebase_storage.Reference folderRef =
        firebase_storage.FirebaseStorage.instance.ref().child(folderPath);

    return folderRef.list().asStream();
  }

  @override
  void initState() {
    super.initState();
    // Start listening for changes when the widget is initialized
    stream = _listenForChanges();
    stream?.listen((firebase_storage.ListResult listResult) {
      // Handle changes in the folder
      // Update the PDF file path if a new bill is uploaded
      setState(() {
        for (var item in listResult.items) {
          if (item.name == 'bill_${widget.roomId}.pdf') {
            pdfFilePath = null; // Reset the PDF file path
            break;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    stream?.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text('RentLog'),
            const Spacer(),
            TextButton(
              onPressed: _confirmExit,
              child: const Text(
                '\t\t\tExit\nRoom',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.13,
              20,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: showBill,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 44.0,
                        vertical: 32.0,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Show Bill',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MakeComplaint(roomId: widget.roomId),
                        ),
                      );
                    }, // Disable the button if roomId is not passed

                    
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 32.0,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Make Complaints',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _navigateToDuedatePage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48.0,
                        vertical: 32.0,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'DueDate',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _navigateToServicePage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 32.0,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Service providers',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
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
