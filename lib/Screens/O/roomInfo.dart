// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:rent_log/Screens/O/MakeDuedate.dart';
import 'package:rent_log/Screens/O/ServiceProvider.dart';
import 'package:rent_log/Screens/O/viewComplaint.dart';
import '../../utils/color_util.dart';
import 'package:rent_log/Screens/O/Bill.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:rent_log/Screens/Auth/Loading.dart';

class OwnerPage extends StatefulWidget {
  final String roomId;

  const OwnerPage({Key? key, required this.roomId}) : super(key: key);

  @override
  _OwnerPageState createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  late String _uuid;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _uuid = widget.roomId;
  }

  Future<void> _copyUuidToClipboard() async {
    setState(() {
      _isLoading = true;
    });

    Clipboard.setData(ClipboardData(text: _uuid));

    final storageRef = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('rooms')
        .child(_uuid);

    await storageRef.child('demo.txt').putString('This is a demo file.',
        format: firebase_storage.PutStringFormat.raw);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room_id copied to clipboard')),
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToBillPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillInputPage(
          roomId: _uuid,
        ),
      ),
    );
  }

  void _navigateToComplaintPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewComplaint(
          roomId: _uuid,
        ),
      ),
    );
  }

  void _navigateToDuedatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Duedate(
          roomId: _uuid,
        ),
      ),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).size.height * 0.10,
                    20,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: _navigateToBillPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 34.0,
                              vertical: 25.0,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Create Bill',
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
                          onPressed: _navigateToComplaintPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                              vertical: 25.0,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Complaints',
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
                                builder: (context) =>
                                    ServiceProviders(roomId: _uuid),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28.0,
                              vertical: 15.0,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Add Service\n\t\tProviders',
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
                              horizontal: 18.0,
                              vertical: 25.0,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Mark Due Date',
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
                          onPressed: _copyUuidToClipboard,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 19.0,
                              vertical: 25.0,
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'Copy Room_id',
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
