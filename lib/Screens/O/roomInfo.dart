// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:rent_log/Screens/O/MakeDuedate.dart';
import 'package:rent_log/Screens/O/ServiceProvider.dart';
import 'package:rent_log/Screens/O/viewComplaint.dart';
import '../../utils/color_util.dart';
import 'package:rent_log/Screens/O/Bill.dart';



class OwnerPage extends StatefulWidget {
  final String roomId;

  const OwnerPage({Key? key, required this.roomId}) : super(key: key);

  @override
  _OwnerPageState createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  late String _uuid;

  @override
  void initState() {
    super.initState();
    _uuid = widget.roomId;
  }

  void _copyUuidToClipboard() {
    Clipboard.setData(ClipboardData(text: _uuid));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room_id copied to clipboard')),
    );
  }

  void _navigateToBillPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  BillInputPage(roomId: _uuid,),
      ),
    );
  }

  void _navigateToComplaintPage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ViewComplaint(roomId: _uuid,),
    ),
  );
}

 void _navigateToDuedatePage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Duedate(roomId: _uuid,),
    ),
  );
}




 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text('RentLog',),
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
              MediaQuery.of(context).size.height * 0.08,
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
                        vertical: 32.0,
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
                        vertical: 32.0,
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
                          builder: (context) => ServiceProviders(roomId: _uuid,),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 22.0,
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
                        horizontal: 23.0,
                        vertical: 32.0,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Mark Duedate',
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
                        horizontal: 20.0,
                        vertical: 32.0,
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
