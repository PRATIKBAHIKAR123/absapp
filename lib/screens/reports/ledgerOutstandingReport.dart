import 'dart:convert';

import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/comman-bottomsheet.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/services/reportsService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../global/styles.dart';
import '../../../layouts/absdrawer.dart';
import '../comman-widgets/invoice-dialog.dart';

class LedgerOutstandingScreen extends StatefulWidget {
  const LedgerOutstandingScreen({super.key});

  @override
  State<LedgerOutstandingScreen> createState() => _LedgerOutstandingScreen();
}

class _LedgerOutstandingScreen extends State<LedgerOutstandingScreen> {
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

  bool isLoading = true;

  String userData = '';
  late String currentSessionId;
  List spIds = [0, 1, 2, 3, 4, 5, 6, 7];
  List<Map<String, dynamic>>? Invoices;
  String searchText = '';
  int? ledgerid;
  List<Map<String, String>> totalData = [
    {'Total Rows': '00'},
    {'Total Amount': '00'},
    {'Pending Amount': '00'}
  ];
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();

  late String fromDate;
  late String toDate;

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
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
          getList(); // Call getList() after loading user data
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
        "ledgers": [ledgerid],
        "detailed": false,
        "toDate": formattedToDate,
        "isOverDueOnBillDate": false,
        "sessionId": currentSessionId
      };

      var response = await ledgerOutstandingReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          int totalRows = 0;
          double totalAmount = 0;
          double pendingAmount = 0;

          // Calculate totals
          for (var invoice in Invoices!) {
            totalRows++;
            if (invoice['opening'] != null) {
              totalAmount += invoice['opening'];
            }
            if (invoice['pending'] != null) {
              pendingAmount += invoice['pending'];
            }
          }
          totalData = [
            {'Total Rows': totalRows.toString()},
            {'Total Amount': totalAmount.toString()},
            {'Pending Amount': pendingAmount.toString()}
          ];
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found'),
          ),
        );
        setState(() {
          isLoading = false;
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

  void ledgerChange(String ledger) {
    print('ledger' + ledger);
    setState(() {
      searchText = ledger;
    });
    //getList();
  }

  ledgerSelect(Map<String, dynamic> ledger) {
    print('ledger' + ledger.toString());
    ledgerid = ledger['id'];
    if (ledgerid != null) {
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
                    'Ledger Outstanding',
                    style: listTitle,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                      fixedSize: Size(95, 20),
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
                        //barrierColor: Colors.transparent, // No backdrop
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
                                child: FilterPopup(
                                  onSubmit: updateDates,
                                  initialFromDate: fromDate,
                                  initialToDate: toDate,
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
                    child: SearchLedger(
                      onTextChanged: ledgerChange,
                      onledgerSelects: ledgerSelect,
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
                        String formattedDate = 'Unknown Date';

                        // Check if billDate is not null and then parse
                        if (invoice['date'] != null) {
                          DateTime date = DateTime.parse(invoice['date']);
                          formattedDate = DateFormat('dd MM yyyy').format(date);
                        }

                        return GestureDetector(
                            onTap: () => {
                                  // showDialog(
                                  //   context: context,
                                  //   builder: (BuildContext context) {
                                  //     return InvoiceDialog(
                                  //       sessionId: currentSessionId,
                                  //       id: invoice['billNo'] != null
                                  //           ? invoice['billNo'].toString()
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
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/calendar.png',
                                            height: 16,
                                            width: 16,
                                          ),
                                          const SizedBox(width: 10),
                                          Text('$formattedDate',
                                              style: carddate),
                                        ],
                                      )
                                    ]),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Bill No',
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
                                            child: Text('${invoice['billNo']}',
                                                style: cardcontent),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Amount',
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
                                                '₹${formatDoubleIntoAmount(invoice['opening'])}',
                                                style: cardcontent),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Voucher',
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
                                            child: Text('${invoice['voucher']}',
                                                style: cardcontent),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Pending',
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
                                                '₹${formatDoubleIntoAmount(invoice['pending'])}',
                                                style: crAmnt),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Over Due (In days)',
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
                                            child: Text('${invoice['overDue']}',
                                                style: crAmnt),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () => {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return InvoiceDialog(
                                                  sessionId: '',
                                                  id: '',
                                                );
                                              },
                                            )
                                          },
                                          child: Image.asset(
                                            'assets/icons/docdblu.png',
                                            width: 24,
                                            height: 24,
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
            ],
          ),
        ),
      ),
      bottomSheet: commanBottomSheet(totalData),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
