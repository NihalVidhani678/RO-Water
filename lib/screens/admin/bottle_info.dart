import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:water_service/helper/db_handler.dart';
import 'package:water_service/screens/admin/admin_navigator.dart';

class BottleInfo extends StatefulWidget {
  String bottleID;

  BottleInfo({
    required this.bottleID,
  });

  @override
  State<BottleInfo> createState() => _BottleInfoState();
}

class _BottleInfoState extends State<BottleInfo> {
  bool isLoading = false;

  printSticker() async {
    String qr = widget.bottleID;
    final qrValidationResult = QrValidator.validate(
      data: qr,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        gapless: true,
        embeddedImageStyle: null,
        embeddedImage: null,
      );
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      String path = '$tempPath/$ts.png';

      final picData =
          await painter.toImageData(2048, format: ImageByteFormat.png);
      final buffer = picData!.buffer;
      await File(path).writeAsBytes(
          buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes));

      final qrImage = pw.MemoryImage(
        File(path).readAsBytesSync(),
      );

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a6,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Image(
                  qrImage,
                  height: 250,
                ),
                pw.SizedBox(
                  height: 50,
                ),
                pw.Text(
                  widget.bottleID,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ],
            ); // Center
          },
        ),
      );
      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save());
    } else {
      Fluttertoast.showToast(msg: "An error has occured. Please try again.");
    }
  }

  deleteBottle() async {
    setState(() {
      isLoading = true;
    });
    DBHandler dbHandler = new DBHandler();
    bool bottleDoc = await dbHandler.deleteBottle(widget.bottleID);
    if (bottleDoc) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Bottle has been deleted");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AdminNavigator(
            initialIndex: 4,
          ),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "An error has occured. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Bottle Info (${widget.bottleID})",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => AdminNavigator(
                  initialIndex: 4,
                ),
              ),
              (route) => false,
            );
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
          ),
          Center(
            child: QrImage(
              data: widget.bottleID,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          if (!isLoading)
            Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: printSticker,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 25,
                        ),
                        child: Text(
                          "Print Sticker",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: GestureDetector(
                    onTap: deleteBottle,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 25,
                        ),
                        child: Text(
                          "Delete Bottle Data",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
