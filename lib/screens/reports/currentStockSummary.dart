import 'dart:convert';
import 'dart:ffi';

import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/itemsearch.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/screens/reports/itemFilterPopup.dart';
import 'package:abs/services/reportsService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../global/styles.dart';
import '../../../layouts/absdrawer.dart';
import '../comman-widgets/invoice-dialog.dart';

class CurrentStockSummaryScreen extends StatefulWidget {
  const CurrentStockSummaryScreen({super.key});

  @override
  State<CurrentStockSummaryScreen> createState() =>
      _CurrentStockSummaryScreen();
}

class _CurrentStockSummaryScreen extends State<CurrentStockSummaryScreen> {
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

  final TextStyle crAmnt = const TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(229, 96, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  bool isLoading = false;

  String userData = '';
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();
  late String currentSessionId;
  List spIds = [0, 1, 2, 3, 4, 5, 6, 7];
  List<Map<String, dynamic>>? Invoices;
  String searchText = '';
  int? itemsid;

  late String fromDate;
  late String toDate;
  String itemCode = '';
  String itemBrand = '';
  String itemCat = '';
  String itemSubCat = '';
  String itemType = '';
  String itemBrandCode = '';
  bool isallStockPlaces = false;
  int? spid;
  List<Map<String, String>> totalData = [
    {'Total Rows': '00'},
    {'Opening': '00'},
    {'Running': '00'},
    {'Closing': '00'}
  ];

  void updateDates(
      String from,
      String to,
      String _itemCode,
      String _itemBrand,
      String _itemCat,
      String _ItemSubCat,
      String _itemType,
      String _itemBrandCode,
      String spId,
      bool allStockPlaces) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    setState(() {
      itemCode = _itemCode;
      itemBrand = _itemBrand;
      itemCat = _itemCat;
      itemSubCat = _ItemSubCat;
      itemType = _itemType;
      itemBrandCode = _itemBrandCode;
      spid = int.tryParse(spId);
      isallStockPlaces = allStockPlaces;
    });
    getList();
  }

  @override
  void initState() {
    super.initState();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(lastDayOfMonth);
    loadUserData();
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
          // Call getList() after loading user data
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

  getList() async {
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);

    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "brand": itemBrand == '' ? null : itemBrand,
        "category": itemCat == '' ? null : itemCat,
        "sizes": itemSubCat == '' ? null : itemSubCat,
        "type": itemType == '' ? null : itemType,
        "itemGroup": itemBrandCode == '' ? null : itemBrandCode,
        "item_CodeTxt": itemCode == '' ? null : itemCode,
        "name": null,
        "itemId": itemsid,
        "spId": spid,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "reorderList": false,
        "detailed": false,
        "stockoption": 1,
        "usedFor": null,
        "sessionId": currentSessionId
      };

      var response = await currentStockSummaryReportService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);

          isLoading = false;
          int totalRows = 0;
          double opening = 0;
          double running = 0;
          double closing = 0;

          // Calculate totals
          for (var invoice in Invoices!) {
            totalRows++;
            if (invoice['type'] == 'Opening Amount') {
              opening += invoice['debit'];
            }
            if (invoice['type'] == 'Current Total') {
              running += invoice['debit'];
            }
            if (invoice['type'] == 'Closing Amount') {
              closing += invoice['debit'];
            }
          }
          totalData = [
            {'Total Rows': totalRows.toString()},
            {'Opening': opening.toString()},
            {'Running': running.toString()},
            {'Closing': closing.toString()}
          ];
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void itemsChange(String items) {
    print('items' + items);
    setState(() {
      searchText = items;
    });
    //getList();
  }

  itemsSelect(Map<String, dynamic> items) {
    print('items' + items.toString());
    itemsid = items['iid'];
    if (itemsid != null) {
      getList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AbsAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Stock Summary',
                    style: listTitle,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: BorderSide(
                            width: 2,
                            color: abs_blue), // Border color and width
                      ),
                    ),
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        // barrierColor: Colors.transparent, // No backdrop
                        barrierLabel: 'Popup', // Adding barrierLabel
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Material(
                              type: MaterialType.transparency,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: ItemFilterPopup(
                                  onSubmit: updateDates,
                                  initialFromDate: fromDate,
                                  initialToDate: toDate,
                                  initialValues: {
                                    'itemCode': itemCode,
                                    'brand': itemBrand,
                                    'category': itemCat,
                                    'subCategory': itemSubCat,
                                    'type': itemType,
                                    'brandCode': itemBrandCode,
                                    'stockPlace': spid,
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 1),
                              end: Offset(0, 0),
                            ).animate(animation),
                            child: child,
                          );
                        },
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(color: abs_blue),
                        ),
                        Image.asset(
                          'assets/icons/filter.png',
                          width: 20,
                          height: 20,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SearchItem(
                      onTextChanged: itemsChange,
                      onitemselects: itemsSelect,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
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
                                  //       id: invoice['BillNo'] != null
                                  //           ? invoice['BillNo'].toString()
                                  //           : '0',
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
                                          Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      260), // Adjust the maxWidth as needed
                                              child: Text(
                                                  '${invoice['Item Code']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: cardcontent)),
                                        ],
                                      ),
                                    ]),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    if (invoice['Name'] != null &&
                                        invoice['Name'] != "")
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text('Name ',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(':',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      260), // Adjust the maxWidth as needed
                                              child: Text(
                                                '${invoice['Name'] ?? ''}',
                                                overflow: TextOverflow.ellipsis,
                                                style: cardcontent,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (invoice['Category'] != null &&
                                        invoice['Category'] != "")
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text('Category ',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(':',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      260), // Adjust the maxWidth as needed
                                              child: Text(
                                                '${invoice['Category'] ?? ''}',
                                                overflow: TextOverflow.ellipsis,
                                                style: cardcontent,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (invoice['Type'] != null &&
                                        invoice['Type'] != "")
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text('Type ',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(':',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      260), // Adjust the maxWidth as needed
                                              child: Text(
                                                '${invoice['Type'] ?? ''}',
                                                overflow: TextOverflow.ellipsis,
                                                style: cardcontent,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (invoice['Brand'] != null &&
                                        invoice['Brand'] != "")
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text('Brand ',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(':',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      260), // Adjust the maxWidth as needed
                                              child: Text(
                                                '${invoice['Brand'] ?? ''}',
                                                overflow: TextOverflow.ellipsis,
                                                style: cardcontent,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    if (invoice['Group'] != null &&
                                        invoice['Group'] != "")
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text('Group ',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(':',
                                                style: cardmaincontent),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      260), // Adjust the maxWidth as needed
                                              child: Text(
                                                '${invoice['Group'] ?? ''}',
                                                overflow: TextOverflow.ellipsis,
                                                style: cardcontent,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Balance',
                                              style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child:
                                              Text(':', style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                            constraints: BoxConstraints(
                                                maxWidth:
                                                    260), // Adjust the maxWidth as needed
                                            child: Text(
                                              '₹${formatDoubleIntoAmount(invoice['Balance'])}',
                                              overflow: TextOverflow.ellipsis,
                                              style: crAmnt,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            ));
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
