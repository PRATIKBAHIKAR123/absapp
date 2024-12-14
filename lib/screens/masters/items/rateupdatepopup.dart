import 'dart:convert';
import 'dart:ffi';

import 'package:abs/global/styles.dart';
import 'package:abs/services/itemService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemRateUpdatePopup extends StatefulWidget {
  final Function(String, String) onSubmit; // Define callback function

  final int? itemId;
  ItemRateUpdatePopup({required this.onSubmit, this.itemId});

  @override
  _FilterPopupState createState() => _FilterPopupState();
}

class _FilterPopupState extends State<ItemRateUpdatePopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController itemrate = TextEditingController();
  bool isItemLoading = false;
  late String currentSessionId;
  var ItemInfo;

  @override
  void dispose() {
    itemrate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<Map<String, dynamic>> getItemInfo(itemID) async {
    setState(() {
      isItemLoading = true;
    });
    try {
      var requestBody = {"id": itemID, "sessionId": currentSessionId};

      var response = await getItemInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          ItemInfo = Map<String, dynamic>.from(decodedData);
          itemrate.text = ItemInfo['std_Sell_Rate'].toString();
        });
      }
      setState(() {
        isItemLoading = false;
      });
      return ItemInfo;
    } catch (e) {
      print('Error: $e');
      setState(() {
        isItemLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
    return ItemInfo;
  }

  Future<Map<String, dynamic>> updateItem() async {
    setState(() {
      isItemLoading = true;
    });
    try {
      var requestBody = ItemInfo;
      requestBody['item_ID'] = null;
      requestBody['isDiscountAllowed'] = false;
      requestBody['sessionId'] = currentSessionId;
      requestBody['std_Sell_Rate'] = itemrate.text;
      var response = await updateitemService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        widget.onSubmit('', '');
      }
      setState(() {
        isItemLoading = false;
      });
      return ItemInfo;
    } catch (e) {
      print('Error: $e');
      setState(() {
        isItemLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
    return ItemInfo;
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
          getItemInfo(widget.itemId);
          print('Loaded currentSessionId: $currentSessionId');
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

  void submit() {
    updateItem();
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
        height: 190,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isItemLoading
                    ? CircularProgressIndicator()
                    : Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: itemrate,
                          decoration: InputDecoration(
                              hintText: 'Rate',
                              border: borderStyle,
                              label: Text('Rate')),
                        ),
                      ),
                SizedBox(width: 16), // Add spacing between the text fields
              ],
            ),
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
                  submit();
                },
                child: Text(
                  "Update",
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
