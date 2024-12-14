import 'dart:convert';
import 'dart:ffi';

import 'package:abs/global/styles.dart';
import 'package:abs/services/groupService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LedgerOutSummaryFilterPopup extends StatefulWidget {
  final Function(int?, String) onSubmit; // Define callback function

  final int? groupid;
  final String? initialToDate;
  LedgerOutSummaryFilterPopup(
      {required this.onSubmit, this.groupid, this.initialToDate});

  @override
  _LedgerOutSummaryFilterPopupState createState() =>
      _LedgerOutSummaryFilterPopupState();
}

class _LedgerOutSummaryFilterPopupState
    extends State<LedgerOutSummaryFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  String _toDate = '';
  late String currentSessionId;
  List<Map<String, dynamic>>? grouplist;
  int? groupid;

  @override
  void dispose() {
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();

    if (widget.initialToDate != null) {
      toDate.text = DateFormat('dd/MM/yyyy').format(
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialToDate!));
    }
    if (widget.groupid != null) {
      groupid = widget.groupid;
    }
  }

  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('userData');

    if (userDataString != null) {
      try {
        Map<String, dynamic> userData = jsonDecode(userDataString);
        String? currentSessionId = userData['user']['currentSessionId'];

        if (currentSessionId != null) {
          setState(() {
            this.currentSessionId = currentSessionId;
          });
          print('Loaded currentSessionId: $currentSessionId');
          getGroupList(); // Call getList() after loading user data
        } else {
          print('currentSessionId is null or not found in userData');
        }
      } catch (e) {
        print('Error parsing userData JSON: $e');
      }
    } else {
      print('No userData found in SharedPreferences');
    }
  }

  getGroupList() async {
    try {
      var requestBody = {"sessionId": currentSessionId};

      var response = await groupSearchService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          grouplist = List<Map<String, dynamic>>.from(decodedData['list']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
  }

  Future<void> onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2100),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    setState(() {
      fromDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  Future<void> onTapToDateFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (pickedDate == null) return;

    setState(() {
      toDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void submitDate() {
    String formattedToDate =
        toDate.text.isNotEmpty ? '${toDate.text} 23:59:59' : '';

    widget.onSubmit(groupid, formattedToDate);
    Navigator.of(context).pop();

    print('groupid: $groupid');
    print('toDate: $formattedToDate');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Container(
        height: 220,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButtonFormField<int>(
              value: groupid,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Group',
              ),
              items: grouplist?.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id'] as int?,
                  child: Text(item['name'] as String),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  groupid = newValue;
                });
              },
            ),

            SizedBox(height: 16), // Add spacing between the text fields
            TextFormField(
              controller: toDate,
              decoration: InputDecoration(hintText: 'To', border: borderStyle),
              onTap: () => onTapToDateFunction(context: context),
            ),

            SizedBox(height: 16),
            Container(
              height: 42,
              width: 360,
              decoration: BoxDecoration(
                color: abs_blue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  submitDate();
                },
                child: Text(
                  "Apply Filter",
                  style: GoogleFonts.poppins(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
