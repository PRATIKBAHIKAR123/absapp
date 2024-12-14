import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:abs/global/invoiceTypes.dart';
import 'package:abs/global/styles.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/salesService.dart';
import 'package:abs/services/sessionIdFetch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:whatsapp_share/whatsapp_share.dart';

class InvoiceDialog extends StatefulWidget {
  final String sessionId;
  final String id;
  final Map<String, dynamic>? invoice;
  final InvoiceType? invoiceType;
  final int? invType;
  InvoiceDialog(
      {required this.sessionId,
      required this.id,
      this.invoice,
      this.invType,
      this.invoiceType});

  @override
  State<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<InvoiceDialog> {
  final ButtonStyle btnStyle = ElevatedButton.styleFrom(
    padding: EdgeInsets.only(left: 10, right: 10),
    backgroundColor: abs_blue,
    // fixedSize: Size(146, 37),
    shape: RoundedRectangleBorder(
      // Change your radius here
      borderRadius: BorderRadius.circular(5),
    ),
  );

  final TextStyle btnText = const TextStyle(color: Colors.white, fontSize: 12);
  final String message = 'Please find the attached invoice.';
  String currentSessionId = '';
  List<dynamic>? printReports = [];
  String? selectedReportName;
  String? reportFileName;

  Uint8List? pdfBytes;

  bool isLoading = true;
  List<Map<String, dynamic>>? ledgers = [];
  int? ledgerID;
  bool isPrintBtnLoading = false;
  String? mobileNumber;
  int? printCode;

  @override
  initState() {
    super.initState();
    loadSessionId();
    if (widget.invoice != null) {
      loadSessionId();
      ledgerID = widget.invoice!['ledger_ID'];
      print('widget.invoice${widget.invoice}');

      getLedgers();
      getInvoiceDescription(widget.invoiceType);
    }
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    if (sessionId != null) {
      setState(() async {
        currentSessionId = sessionId;
        await getSetupInfoData();

        getPrintCode();
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
  }

  getSetupInfoData() async {
    try {
      var requestBody = {
        "invtype": widget.invType,
        "fromInvoice": true,
        "sessionId": currentSessionId
      };

      var response = await getSetupInfoService(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          printReports = decodedData['printReports'];

          selectedReportName = printReports!.firstWhere(
              (report) => report['isDefault'] == true)['reportName'];
          reportFileName = printReports!
              .firstWhere((report) => report['isDefault'] == true)['fileName']
              .replaceFirst(RegExp(r'^\\+'), '');
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  String getInvoiceDescription(InvoiceType? invoiceType) {
    return InvoiceVoucherTypesObjByte[invoiceType] ?? 'Unknown Invoice Type';
  }

  getLedgers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      setState(() {
        ledgers = ledgerList
            .map((item) => jsonDecode(item) as Map<String, dynamic>)
            .toList();
        Map<String, dynamic>? ledger = ledgers?.firstWhere(
          (ledger) => ledger['id'] == ledgerID,
          orElse: () => {},
        );

        if (ledger != null) {
          mobileNumber = ledger['mobile'];
        }
        print('ledger$ledger');
      });
      print('mobileNumber$mobileNumber');
    }

    // Trigger a rebuild to update the UI
  }

  submitPrint() async {
    setState(() {
      isPrintBtnLoading = true;
    });
    await getPdf();
    setState(() {
      isPrintBtnLoading = false;
    });
  }

  getPdf() async {
    try {
      var requestBody = {
        "id": widget.id,
        "invType": widget.invType,
        "reportName": reportFileName,
        "sessionId": currentSessionId
      };

      var response = await getInvoicePdf(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          pdfBytes = response.bodyBytes;

          isLoading = false;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return buildInvoice();
            },
          );
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  getPrintCode() async {
    try {
      var requestBody = {
        "invCode": widget.invoice!['invCode'],
        "sessionId": currentSessionId
      };

      var response = await getInvoicePrintCode(requestBody);

      if (response.statusCode == 200) {
        setState(() {
          var decodedData = jsonDecode(response.body);
          printCode = decodedData['printCode'];
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  Future<void> _shareOnWhatsApp() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice.pdf');
      await file.writeAsBytes(pdfBytes!);

      // // After launching WhatsApp, let the user attach the file manually
      // await Future.delayed(
      //     Duration(seconds: 2)); // Give WhatsApp time to open

      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      print('Error sharing PDF via WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while sharing"),
        ),
      );
    }
  }

  Future<void> shareOnWhatsApp() async {
    int? printCode_ = printCode;
    int companyId_ = 33;
    String shortenedUrl = encodeData(printCode_, companyId_);
    final String phoneNumber = '9168488533';
    final String message =
        'https://erp.abssoftware.in/#/print/invoice?printCode=$shortenedUrl';
    String invTypeText = getInvoiceDescription(widget.invoiceType);
    String name = widget.invoice!['partyName'];
    String billNumber = widget.invoice!['bill_No'];
    DateTime date = DateTime.parse(widget.invoice!['date']);
    String formattedDate = DateFormat('dd/MM/yyyy').format(date);
    String amount = widget.invoice!['grandTotal'].toString();
    String documentLink =
        "https://erp.abssoftware.in/#/print/invoice?printCode=$shortenedUrl";

    String text = '''
$invTypeText
*$name*
Bill Number: $billNumber
Date: $formattedDate
Amount: $amount

Document Link: $documentLink
''';

    try {
      // Save the PDF bytes to a file in the temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice.pdf');
      await file.writeAsBytes(pdfBytes!);

      // First, launch WhatsApp with a pre-filled message to the specific number
      String whatsappUrl =
          'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(text)}';
      if (await canLaunchUrlString(whatsappUrl)) {
        await launchUrlString(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );

        // // After launching WhatsApp, let the user attach the file manually
        // await Future.delayed(
        //     Duration(seconds: 2)); // Give WhatsApp time to open

        // await Share.shareXFiles([XFile(file.path)], text: message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WhatsApp is not installed"),
          ),
        );
      }
    } catch (e) {
      print('Error sharing PDF via WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while sharing"),
        ),
      );
    }
  }

  String encodeData(int? printCode, int companyId) {
    String dataToEncrypt = 'printCode=$printCode&companyId=$companyId';

    // Step 2: Base64 encode the data string
    String base64Encoded = base64Encode(utf8.encode(dataToEncrypt));

    // Step 3: Remove any non-alphanumeric characters (including padding '=')
    String result = base64Encoded.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(10),
      backgroundColor: const Color.fromARGB(255, 192, 191, 191),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 649,
        child: Column(
          children: <Widget>[
            // Add your other widgets here, e.g., a title or header

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/icons/Close.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            Expanded(
              child: printReports!.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: printReports!.length,
                      itemBuilder: (context, index) {
                        String reportName = printReports![index]['reportName'];
                        return RadioListTile<String>(
                          title: Text(printReports![index]['isDefault'] == true
                              ? '$reportName (Default)'
                              : '$reportName'),
                          value: reportName,
                          groupValue: selectedReportName,
                          onChanged: (String? value) {
                            setState(() {
                              selectedReportName = value;
                              reportFileName = printReports![index]['fileName']!
                                  .replaceFirst(RegExp(r'^\\+'), '');
                            });
                            print('Selected report: $value');
                          },
                        );
                      },
                    ),
            ),
            Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5)),
                child: ElevatedButton(
                  onPressed: () {
                    submitPrint();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isPrintBtnLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit',
                              style: btnText,
                            )
                    ],
                  ),
                  style: btnStyle,
                )),
          ],
        ),
      ),
    );
  }

  Widget buildInvoice() {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: const Color.fromARGB(255, 192, 191, 191),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 629,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset('assets/icons/Close.png'),
                ),
              ],
            ),
            Expanded(
              child: SfPdfViewerTheme(
                  data: SfPdfViewerThemeData(backgroundColor: Colors.white),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SfPdfViewer.memory(pdfBytes!)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: btnStyle,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/docdblu.png',
                        color: Colors.white,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Download',
                        style: btnText,
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: btnStyle,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/Print.png',
                        color: Colors.white,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        'Print Invoice',
                        style: btnText,
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _shareOnWhatsApp,
                  style: btnStyle,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/whatsapp.png', // Add your WhatsApp icon here
                        color: Colors.white,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Share',
                        style: btnText,
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
