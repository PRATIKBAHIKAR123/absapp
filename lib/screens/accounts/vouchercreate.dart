import 'dart:convert';

import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/accounts/addvoucherpopup.dart';
import 'package:abs/screens/accounts/paymentVoucher.dart';
import 'package:abs/screens/comman-widgets/comman-bottomsheet.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/services/accountService.dart';
import 'package:abs/services/salesService.dart';
import 'package:abs/services/setupInfoService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../global/styles.dart';
import '../../../layouts/absdrawer.dart';
import '../comman-widgets/invoice-dialog.dart';

class createVoucherScreen extends StatefulWidget {
  String type;
  String action;
  int? id;
  createVoucherScreen(
      {super.key, required this.type, required this.action, this.id});

  @override
  State<createVoucherScreen> createState() => _createVoucherScreen();
}

class _createVoucherScreen extends State<createVoucherScreen> {
  final borderColor = Colors.grey.shade300;
  final TextStyle cardHeader = const TextStyle(
    fontSize: 15,
    color: abs_blue,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle carddate = const TextStyle(
    fontSize: 14,
    color: abs_grey,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle cardmaincontent = const TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(0, 0, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle cardcontent = const TextStyle(
    fontSize: 13,
    color: abs_blue,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle hintTextStyle = GoogleFonts.urbanist(
    fontSize: 15,
    color: const Color.fromRGBO(131, 145, 161, 1),
    fontWeight: FontWeight.w500,
  );
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  GlobalKey<SearchLedgerState> searchLedgerKey = GlobalKey<SearchLedgerState>();
  bool isLoading = false;
  bool isBtnLoading = false;
  String breadcrumbTitle1 = 'Voucher';
  String breadcrumbTitle2 = '';
  String pageTitle = '';
  String breadcrumbTitle3 = '';
  String lblbillNo = '';
  List<int> createPermission = [];
  List<int> utilityPermission = [];
  int editPermission = 0;
  int deletePermission = 0;
  int viewPermission = 0;
  int? invTypeid;
  bool? isCredit;
  final TextEditingController amount = TextEditingController();
  final TextEditingController billNo = TextEditingController();
  TextEditingController billDateController = TextEditingController();
  String billDate = '';
  int? selectedLedgerId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int voucherNo = 2;
  String userData = '';
  late String currentSessionId;
  List spIds = [];
  List<dynamic>? Invoices;
  String searchText = '';
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();
  late String fromDate;
  late String toDate;
  List<Map<String, String>> totalData = [
    {'Total Rows': '00'},
    {'Total Taxable Value': '00'},
    {'Grand Total ': '00'}
  ];
  Map<String, dynamic> ledger_ID_Object = {};
  Map<String, dynamic> setupInfoData = {};

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
    } else {
      billDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      billDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    }

    resolveValuesForType(widget.type, widget.action);
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(lastDayOfMonth);
    loadUserData();
  }

  String? validateLedger(Map<String, dynamic>? ledger) {
    if (ledger == null || ledger.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> setuInfoData() async {
    setupInfoData = await getSetupInfoData(invTypeid, false, currentSessionId);
    spIds = setupInfoData['billingPlaces']
        .map<int>((item) => item['spId'] as int)
        .toList();
    print('spIds: $spIds');
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
          await setuInfoData();
          if (widget.id != null) {
            await getVoucher();
          }

          //getList(); // Call getList() after loading user data
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

  void ledgerChange(String ledger) {
    print('ledger' + ledger);
    setState(() {
      searchText = ledger;
    });
  }

  void ledgerSelects(Map<String, dynamic> ledger) {
    print('ledgerselect $ledger');
    setState(() {
      selectedLedgerId = ledger['id'];
    });
  }

  getVoucher() async {
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "id": widget.id,
        "invType": invTypeid,
        "fromInvoice": true,
        "sessionId": currentSessionId
      };

      var response = await getVoucherDetails(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        setState(() async {
          var object = decodedData;
          Invoices = object['ledgerDetails'];
          DateTime parsedDate =
              DateFormat('yyyy-MM-ddTHH:mm:ss').parse(object['date']);

          // Format the date to the desired output format
          billDateController.text = DateFormat('dd/MM/yyyy').format(parsedDate);
          billNo.text = object['billNo'] ?? '';
          voucherNo = object['voucherNo'] ?? 0;

          for (var item in Invoices!) {
            var ledgerObj = await getLedgerObj(item['ledger_ID']);
            print('ledgerObj$ledger_ID_Object');
            item['name'] = ledger_ID_Object['name'];
          }
        });
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

  submit() {
    print('submit');
    if (Invoices != null) {
      if (widget.id != null) {
        updateVoucher();
      } else {
        createVoucher();
      }
    } else {
      print('Invoices$Invoices');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add Ledger"),
        ),
      );
    }
  }

  createVoucher() async {
    setState(() {
      isBtnLoading = true;
    });
    try {
      var requestBody = {
        "id": widget.id ?? null,
        "narration": null,
        "voucher_No": voucherNo,
        "date": DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()),
        "billNo": null,
        "ledgerID": Invoices!.first['ledger_ID'],
        "spId": 0,
        "hasCashFlow": true,
        "amount": Invoices!.first['amount'],
        "gstType": 0,
        "isRoundOff": true,
        "isPDC": false,
        "profit": 0,
        "profitPer": 0,
        "isSalesSpecific": true,
        "projectSiteId": null,
        "toLedgerId": 0,
        "billType": 0,
        "billStatus": 0,
        "isRcm": true,
        "baseCurrency": 2,
        "convertedCurrency": null,
        "convertedRate": 0,
        "convertedGrandTotal": 0,
        "recAmt": 0,
        "schemePointValue": 0,
        "type": invTypeid,
        "useInCompany": true,
        "documents": null,
        "projectSiteAddress": null,
        "isCredit": isCredit,
        "ledgerDetails": Invoices,
        "sessionId": currentSessionId
      };

      var response = await createVoucherService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isBtnLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => paymentVoucherListScreen()),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isBtnLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  updateVoucher() async {
    setState(() {
      isBtnLoading = true;
    });
    try {
      var requestBody = {
        "id": widget.id ?? null,
        "narration": null,
        "voucher_No": voucherNo,
        "date": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        "billNo": billNo.text,
        "ledgerID": Invoices!.first['ledger_ID'],
        "spId": 0,
        "hasCashFlow": true,
        "amount": Invoices!.first['amount'],
        "gstType": 0,
        "isRoundOff": true,
        "isPDC": false,
        "profit": 0,
        "profitPer": 0,
        "isSalesSpecific": true,
        "projectSiteId": null,
        "toLedgerId": 0,
        "billType": 0,
        "billStatus": 0,
        "isRcm": true,
        "baseCurrency": 2,
        "convertedCurrency": null,
        "convertedRate": 0,
        "convertedGrandTotal": 0,
        "recAmt": 0,
        "schemePointValue": 0,
        "type": invTypeid,
        "useInCompany": true,
        "documents": null,
        "projectSiteAddress": null,
        "isCredit": isCredit,
        "ledgerDetails": Invoices,
        "sessionId": currentSessionId
      };

      var response = await updateVoucherService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isBtnLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => paymentVoucherListScreen()),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isBtnLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  getLedgerObj(ledgerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      var ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
      ledger_ID_Object = ledgers.where((l) => l['id'] == ledgerId).first;
      ledger_ID_Object["particular"] = ledger_ID_Object['name'];
    }
    print('ledger_ID_Object$ledger_ID_Object');
    return ledger_ID_Object;
  }

  void addVoucher() async {
    if (_formKey.currentState?.validate() ?? false) {
      await getLedgerObj(selectedLedgerId);
      setState(() {
        //isLoading = true;
        Invoices != null ? Invoices : Invoices = [];
        Invoices?.add({
          "ledger_ID": ledger_ID_Object['id'],
          "name": ledger_ID_Object['name'],
          "isDeemedPositive": true,
          "refType": 3,
          "amount": amount.text,
          "isCredit": isCredit,
          "ledger_ID_Object": ledger_ID_Object,
          "vch_Ledger_ID": 0,
          "voucher_ID": 0,
          "isDisabled": null,
          "rowData": null,
          "subDetails": [
            {
              "subDetail_Type": 3,
              "name": null,
              "amount": amount.text,
              "isCredit": isCredit,
              "subDetail_ID": 0,
              "vch_Ledger_ID": 0,
              "invCode": 0,
              "invDate": null,
              "actualAmount": 0,
              "projectId": null,
              "name_object": null
            }
          ],
          "bankDetails": [],
        });
        print('Invoices$Invoices');
        selectedLedgerId = null;

        searchLedgerKey.currentState?.onClearLedger();
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AddVoucherPopup(
              onAddVoucher: (voucherData) async {
                // Handle the voucher data here
                var ledgerObj = await getLedgerObj(voucherData['ledger_ID']);
                setState(() {
                  Invoices?.add({
                    "ledger_ID": voucherData['ledger_ID'],
                    "name": voucherData['name'],
                    "isDeemedPositive": true,
                    "amount": amount.text,
                    "isCredit": isCredit! ? false : true,
                    "ledger_ID_Object": ledgerObj,
                    "vch_Ledger_ID": 0,
                    "voucher_ID": 0,
                    "isDisabled": null,
                    "rowData": null,
                    "subDetails": [
                      {
                        "subDetail_Type": 3,
                        "name": null,
                        "amount": amount.text,
                        "isCredit": isCredit! ? false : true,
                        "subDetail_ID": 0,
                        "vch_Ledger_ID": 0,
                        "invCode": 0,
                        "invDate": null,
                        "actualAmount": 0,
                        "projectId": null,
                        "name_object": null
                      }
                    ],
                    "bankDetails": voucherData['groupId'] == 19
                        ? [
                            {
                              "bankDetail_ID": 0,
                              "vch_Ledger_ID": 0,
                              "instrumentType": 1,
                              "instrumentNo": "",
                              "instrumentDate": DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()),
                              "bankName": null,
                              "branchName": null,
                              "reConcillDate": null,
                              "payerName": voucherData['name'],
                              "amount": amount.text,
                              "crossed": false,
                              "isCr": isCredit! ? false : true
                            }
                          ]
                        : [],
                  });
                  amount.clear();
                });
              },
            );
          });
    } else {
      print('Form is not valid');
    }
  }

  onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2100),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    setState(() {
      billDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      print('billDate$billDate');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AbsAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pageTitle,
                    style: listTitle,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: billNo,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 10.0),
                        labelText: 'Voucher No.',
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: const Color.fromRGBO(247, 248, 249, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      //initialValue: billDate,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 10.0),
                        labelText: 'Bill Date',
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: const Color.fromRGBO(247, 248, 249, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                      controller: billDateController,
                      onTap: () => onTapFunction(context: context),
                    ),
                  )
                ],
              ),
              // const SizedBox(height: 10),
              // Container(
              //   child: DropdownButtonFormField<bool>(
              //     value: isCredit,
              //     decoration: InputDecoration(
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(9),
              //         borderSide: BorderSide(color: borderColor),
              //       ),
              //       errorText:
              //           isCredit == null ? 'This field is required' : null,
              //     ),
              //     items: [
              //       DropdownMenuItem(value: false, child: Text('Dr')),
              //       DropdownMenuItem(value: true, child: Text('Cr')),
              //     ],
              //     onChanged: (value) {
              //       setState(() {
              //         isCredit = value;
              //       });
              //     },
              //     onSaved: (value) {
              //       isCredit = value;
              //     },
              //     // onFieldSubmitted: (_) {
              //     //   widget.focusOnLedger();
              //     // },
              //   ),
              // ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    flex: 4,
                    child: SearchLedger(
                      onTextChanged: ledgerChange,
                      onledgerSelects: ledgerSelects,
                      validator: true ? validateLedger : null,
                      isRequired: true,
                      key: searchLedgerKey,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: abs_blue), // Specify border color and width
                        borderRadius: BorderRadius.circular(
                            8), // Optional: Add border radius
                      ),
                      child: IconButton(
                        color: abs_blue,
                        onPressed: () {},
                        icon: Icon(Icons.list),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: amount,
                      validator: (value) {
                        // Validation function for the email field
                        if (value == null || value.isEmpty) {
                          return 'This value is required.'; // Return an error message if the email is empty
                        }
                        // You can add more complex validation logic here
                        return null; // Return null if the email is valid
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 13.0, horizontal: 10.0),
                        labelText: 'Amount',
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: const Color.fromRGBO(247, 248, 249, 1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(9),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: abs_blue,
                        border: Border.all(
                            color: abs_blue), // Specify border color and width
                        borderRadius: BorderRadius.circular(
                            8), // Optional: Add border radius
                      ),
                      child: TextButton(
                        onPressed: () {
                          addVoucher();
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 60),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Invoices?.length ?? 0,
                      itemBuilder: (context, index) {
                        if (Invoices == null || Invoices!.isEmpty) {
                          return Center(
                            child: Text('No invoices found'),
                          );
                        }
                        var invoice = Invoices![index];
                        return GestureDetector(
                            onTap: () => {
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (BuildContext context) {
                                  //     return InvoiceDialog(
                                  //       sessionId: currentSessionId,
                                  //       id: invoice['invCode'].toString(),
                                  //     );
                                  //   },
                                  // )
                                },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.white,
                              child: ListTile(
                                title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text('CR/DR :',
                                              style: cardmaincontent),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          invoice['isCredit']
                                              ? Text('Cr', style: cardcontent)
                                              : Text('Dr', style: cardcontent)
                                        ],
                                      ),
                                    ]),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text('Ledger  :',
                                                style: cardmaincontent),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text('${invoice['name']}',
                                                style: cardcontent),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            invoice['isCredit']
                                                ? Text('Credit :',
                                                    style: cardmaincontent)
                                                : Text('Debit :',
                                                    style: cardmaincontent),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                                '₹${formatAmount(invoice['amount'].toString())}',
                                                style: cardcontent),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () => {
                                            setState(() {
                                              Invoices!.removeAt(index);
                                            })
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            ));
                      },
                    ),
              const SizedBox(height: 85),
              Container(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    onPressed: () {
                      submit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12), // Padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                      ),
                      elevation: 8, // Shadow
                    ),
                    child: isBtnLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            widget.action == 'edit' ? 'Update' : 'Create',
                            style: TextStyle(color: Colors.white),
                          )),
              )
            ],
          ),
        ),
      )),
      // floatingActionButton: FloatingActionButton(
      //     backgroundColor: abs_blue,
      //     onPressed: () => {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //                 builder: (context) => const RegisterFormScreen()),
      //           )
      //         },
      //     child: const Row(
      //       children: [
      //         Icon(
      //           Icons.add,
      //           color: Colors.white,
      //         ),
      //         Text(
      //           'Add',
      //           style: TextStyle(color: Colors.white),
      //         )
      //       ],
      //     )),
      //bottomSheet: commanBottomSheet(totalData),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  void resolveValuesForType(String type, String action) {
    if (type == 'receipt-voucher') {
      breadcrumbTitle2 = 'Receipt Voucher';
      createPermission = [140];
      utilityPermission = [142];
      editPermission = 139;
      deletePermission = 141;
      viewPermission = 138;
      isCredit = false;
      invTypeid = 18;

      if (action == 'list') {
        pageTitle = 'Voucher Receipt Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'Rec.Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Receipt Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'Rec.Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Receipt Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'Rec.Voucher No.';
      }
    } else if (type == 'payment-voucher') {
      breadcrumbTitle2 = 'Payment Voucher';
      createPermission = [134];
      utilityPermission = [136];
      editPermission = 133;
      deletePermission = 135;
      viewPermission = 132;
      isCredit = true;
      invTypeid = 17;

      if (action == 'list') {
        pageTitle = 'Payment Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'Pay.Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Payment Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'Pay.Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Payment Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'Pay.Voucher No.';
      }
    } else if (type == 'contra-voucher') {
      breadcrumbTitle2 = 'Contra Voucher';
      createPermission = [152];
      utilityPermission = [154];
      editPermission = 151;
      deletePermission = 153;
      viewPermission = 150;

      if (action == 'list') {
        pageTitle = 'Contra Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'Contra Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Contra Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'Contra Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Contra Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'Contra Voucher No.';
      }
    } else if (type == 'journal-voucher') {
      breadcrumbTitle2 = 'Journal Voucher';
      createPermission = [146];
      utilityPermission = [148];
      editPermission = 145;
      deletePermission = 147;
      viewPermission = 144;

      if (action == 'list') {
        pageTitle = 'Journal Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'J.Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Journal Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'J.Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Journal Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'J.Voucher No.';
      }
    } else if (type == 'purchase-voucher') {
      breadcrumbTitle2 = 'Purchase Voucher';
      createPermission = [98];
      utilityPermission = [100];
      editPermission = 97;
      deletePermission = 99;
      viewPermission = 96;

      if (action == 'list') {
        pageTitle = 'Purchase Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'Purchase Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Purchase Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'Purchase Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Purchase Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'Purchase Voucher No.';
      }
    } else if (type == 'credit-note') {
      breadcrumbTitle2 = 'Credit Note Voucher';
      createPermission = [68];
      utilityPermission = [70];
      editPermission = 67;
      deletePermission = 69;
      viewPermission = 66;

      if (action == 'list') {
        pageTitle = 'Credit Note Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'Credit Note Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Credit Note Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'Credit Note Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Credit Note Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'Credit Note Voucher No.';
      }
    } else if (type == 'debit-note') {
      breadcrumbTitle2 = 'Debit Note Voucher';
      createPermission = [104];
      utilityPermission = [106];
      editPermission = 103;
      deletePermission = 105;
      viewPermission = 102;

      if (action == 'list') {
        pageTitle = 'Debit Note Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'Debit Note Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Debit Note Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'Debit Note Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Debit Note Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'Debit Note Voucher No.';
      }
    } else if (type == 'sales-voucher') {
      breadcrumbTitle2 = 'Sales Voucher';
      createPermission = [62];
      utilityPermission = [64];
      editPermission = 61;
      deletePermission = 63;
      viewPermission = 60;

      if (action == 'list') {
        pageTitle = 'Sales Voucher';
        breadcrumbTitle3 = 'List';
        lblbillNo = 'Sales Voucher No.';
      } else if (action == 'new') {
        pageTitle = 'Create New Sales Voucher';
        breadcrumbTitle3 = 'New';
        lblbillNo = 'Sales Voucher No.';
      } else if (action == 'edit') {
        pageTitle = 'Sales Voucher Info';
        breadcrumbTitle3 = 'Edit';
        lblbillNo = 'Sales Voucher No.';
      }
    }

    // Use these variables as needed within your Flutter app.
  }
}
