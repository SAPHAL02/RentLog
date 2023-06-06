// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({Key? key}) : super(key: key);

  @override
  _ComplaintPageState createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _complaintController = TextEditingController();

  void _submitComplaint() {
    // Code to handle complaint submission
    String complaintText = _complaintController.text;
    // Perform any necessary actions with the complaint text, such as sending it to the server or storing it locally

    // Show a confirmation dialog or navigate to a success page
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complaint Submitted'),
          content: Text('Your complaint has been submitted: $complaintText'),
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

    // Clear the text field
    _complaintController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _complaintController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Enter your complaint',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitComplaint,
              child: const Text('Submit Complaint'),
            ),
          ],
        ),
      ),
    );
  }
}
