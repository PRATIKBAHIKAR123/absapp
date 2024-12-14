import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddVoucherPopup extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddVoucher;

  AddVoucherPopup({required this.onAddVoucher});

  @override
  _AddVoucherPopupState createState() => _AddVoucherPopupState();
}

class _AddVoucherPopupState extends State<AddVoucherPopup> {
  String? selectedLedgerType = 'Bank';
  List<Map<String, dynamic>>? ledgers = [];
  int? groupId = 19;
  Map<String, dynamic>? selectedLedger;
  bool? onAccounts = true;
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLedgers();
  }

  getLedgers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
      ledgers = ledgerList!
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .where((ledger) => groupId == ledger['group_ID'])
          .toList();
    }

    setState(() {}); // Trigger a rebuild to update the UI
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Voucher'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // DropdownButtonFormField<bool>(
          //   value: onAccounts,
          //   decoration: InputDecoration(
          //     labelText: 'On Accounts',
          //     border: OutlineInputBorder(),
          //   ),
          //   items: [
          //     DropdownMenuItem(value: true, child: Text('Yes')),
          //     DropdownMenuItem(value: false, child: Text('No')),
          //   ],
          //   onChanged: (value) {
          //     setState(() {
          //       onAccounts = value;
          //     });
          //   },
          // ),
          // SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedLedgerType,
            decoration: InputDecoration(
              labelText: 'Ledger Type',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'Bank', child: Text('Bank')),
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
            ],
            onChanged: (value) {
              setState(() {
                selectedLedgerType = value;
                if (selectedLedgerType == 'Bank') {
                  groupId = 19;
                } else {
                  groupId = 18;
                }
              });
              getLedgers();
            },
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedLedger,
            decoration: InputDecoration(
              labelText: 'Select Ledger',
              border: OutlineInputBorder(),
            ),
            items: ledgers!.map((ledger) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: ledger,
                child: Text(ledger['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedLedger = value;
              });
            },
          ),
          // SizedBox(height: 10),
          // TextFormField(
          //   controller: amountController,
          //   decoration: InputDecoration(
          //     labelText: 'Amount',
          //     border: OutlineInputBorder(),
          //   ),
          //   keyboardType: TextInputType.number,
          // ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the popup
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Map<String, dynamic> voucherData = {
              'ledgerType': selectedLedgerType,
              'amount': amountController.text,
              "ledger_ID": selectedLedger!['id'],
              "name": selectedLedger!['name'],
              "isDeemedPositive": false,
              "isCredit": false,
              "groupId": groupId
            };
            widget.onAddVoucher(voucherData);
            Navigator.of(context).pop(); // Close the popup
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
