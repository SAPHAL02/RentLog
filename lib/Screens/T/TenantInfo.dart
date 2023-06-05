// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
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
              appBar: AppBar(title: const Text('PDF')),
              body: Container(
                padding: const EdgeInsets.all(16.0),
                child: PDFView(filePath: pdfFilePath),
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
              content: const Text('The PDF file does not exist.'),
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
            title: const Text('Room ID'),
            content: const Text('The room folder does not exist.'),
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
            title: const Text(
              'RentLog',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
                color: Colors.white,
              ),
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
                    onPressed: () {},
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 44.0,
                        vertical: 32.0,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Due Date',
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
                    onPressed: () {},
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
