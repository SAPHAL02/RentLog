// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../utils/color_util.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class BillInputPage extends StatefulWidget {
  const BillInputPage({Key? key}) : super(key: key);

  @override
  _BillInputPageState createState() => _BillInputPageState();
}

class _BillInputPageState extends State<BillInputPage> {
  final TextEditingController _rentController = TextEditingController();
  final TextEditingController _electricityBillController = TextEditingController();
  final TextEditingController _waterBillController = TextEditingController();
  final TextEditingController _maintenanceChargesController = TextEditingController();
  double _total = 0.0;

  void _calculateTotal() {
    double rentBill = double.tryParse(_rentController.text) ?? 0.0;
    double electricityBill = double.tryParse(_electricityBillController.text) ?? 0.0;
    double waterBill = double.tryParse(_waterBillController.text) ?? 0.0;
    double maintenanceCharges = double.tryParse(_maintenanceChargesController.text) ?? 0.0;

    setState(() {
      _total = electricityBill + waterBill + maintenanceCharges + rentBill;
    });
  }

  Future<void> _createPDF() async {
  final pdf = pw.Document();

  double rentBill = double.tryParse(_rentController.text) ?? 0.0;
  double electricityBill = double.tryParse(_electricityBillController.text) ?? 0.0;
  double waterBill = double.tryParse(_waterBillController.text) ?? 0.0;
  double maintenanceCharges = double.tryParse(_maintenanceChargesController.text) ?? 0.0;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          padding: pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.black,
              width: 2,
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'RentLog',
                style: pw.TextStyle(
                  fontSize: 34,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text('Bill Details', style: pw.TextStyle(fontSize: 30)),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 15),
              pw.Text('Rent (Rs): $rentBill', style: const pw.TextStyle(fontSize: 20)),
              pw.Text('Electricity Bill (Rs): $electricityBill', style: const pw.TextStyle(fontSize: 20)),
              pw.Text('Water Bill (Rs): $waterBill', style: const pw.TextStyle(fontSize: 20)),
              pw.Text('Maintenance Charges (Rs): $maintenanceCharges', style: const pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.Text('Total (Rs): $_total', style: const pw.TextStyle(fontSize: 25)),
            ],
          ),
        );
      },
    ),
  );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill.pdf');
    await file.writeAsBytes(await pdf.save());

    final pdfPath = file.path;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF created successfully. Path: $pdfPath'),
        action: SnackBarAction(
          label: 'Open PDF',
          onPressed: () {
            _openPDF(pdfPath);
          },
        ),
      ),
    );
  }

  Future<void> _openPDF(String filePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFView(filePath: filePath),
      ),
    );
  }

  Future<void> _showBill() async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill.pdf');
    final pdfPath = file.path;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFView(filePath: pdfPath),
      ),
    );
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
              MediaQuery.of(context).size.height * 0.1,
              20,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _rentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Rent (Rs)',
                  ),
                ),
                TextFormField(
                  controller: _electricityBillController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Electricity Bill (Rs)',
                  ),
                ),
                TextFormField(
                  controller: _waterBillController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Water Bill (Rs)',
                  ),
                ),
                TextFormField(
                  controller: _maintenanceChargesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maintenance Charges (Rs)',
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _calculateTotal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Calculate Total',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Total (Rs): $_total',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _createPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Create PDF',
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _showBill();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Show PDF',
                    style: TextStyle(
                      color: Colors.black87,
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
