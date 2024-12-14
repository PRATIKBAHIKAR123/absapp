import 'dart:convert';

import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/comman-bottomsheet.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/itemsearch.dart';
import 'package:abs/screens/comman-widgets/reportbottomsheet.dart';
import 'package:abs/services/reportsService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../global/styles.dart';
import '../../../layouts/absdrawer.dart';
import '../comman-widgets/invoice-dialog.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreen();
}

class _StockReportScreen extends State<StockReportScreen> {
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
  int? itemsid;

  late String fromDate;
  late String toDate;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();
  List<Map<String, String>> totalData = [
    {'Closing': '00'}
  ];
  double openingAmnt = 00;

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

  void getList() async {
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
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "isOpeningStock": false,
        "includeInternalMov": true,
        "stockDetail": false,
        "spIds": null,
        "itemId": itemsid,
        "sessionId": currentSessionId
      };

      var response = await stockReportListService(requestBody);
      var decodedData = jsonDecode(response.body);

      if (response.body.length > 0) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          List<Map<String, dynamic>> tempInvoices =
              List<Map<String, dynamic>>.from(decodedData);

          isLoading = false;
          int totalRows = 0;
          double opening = 0;
          double running = 0;
          double closing = 0;
          openingAmnt = 0;

          for (var invoice in tempInvoices!) {
            totalRows++;
            if (invoice['Type'] == 'Opening') {
              opening += invoice['Balance'];
              openingAmnt += invoice['Balance'];
            }
            if (invoice['Type'] == 'Closing') {
              closing += invoice['Balance'];
            }
          }
          totalData = [
            {'Closing': closing.toString()}
          ];
          Invoices!.removeWhere((invoice) => invoice['Type'] == 'Opening');
          Invoices!.removeWhere((invoice) => invoice['Type'] == 'Closing');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found for selected party'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Stock Report',
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
                          barrierLabel: 'Popup',
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
              const SizedBox(height: 50),
              // Adjust the height and position of the ListView
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                            top: 25, bottom: 150.5, left: 20, right: 20),
                        itemCount: Invoices?.length ?? 0,
                        itemBuilder: (context, index) {
                          if (Invoices == null || Invoices!.isEmpty) {
                            return Center(
                              child: Text('No invoices found'),
                            );
                          }
                          var invoice = Invoices![index];
                          String formattedDate = 'Unknown Date';
                          int debit = 0;
                          int running = 0;
                          String party = '';
                          String bill_no = '';
                          double balance = 0.0;
                          if (invoice['Party'] != null) {
                            party = invoice['Party'];
                          }
                          if (invoice['BillNo'] != null) {
                            bill_no = invoice['BillNo'];
                          }
                          if (invoice['BillDate'] != null) {
                            DateTime date = DateTime.parse(invoice['BillDate']);
                            formattedDate =
                                DateFormat('dd MM yyyy').format(date);
                          }
                          if (invoice['Received'] != null) {
                            debit = invoice['Received'].toInt();
                          }
                          if (invoice['Issued'] != null) {
                            running = invoice['Issued'].toInt();
                          }
                          if (invoice['Balance'] != null) {
                            balance = invoice['Balance'].toDouble();
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${party}',
                                        style: cardHeader,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/icons/calendar.png',
                                          height: 16,
                                          width: 16,
                                        ),
                                        const SizedBox(width: 10),
                                        Text('$formattedDate', style: carddate),
                                      ],
                                    )
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    if (bill_no != null && bill_no != "")
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text('Bill No ',
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
                                                '${bill_no}',
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
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Issued ',
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
                                              '${running}',
                                              overflow: TextOverflow.ellipsis,
                                              style: crAmnt,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Received ',
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
                                              '${debit}',
                                              overflow: TextOverflow.ellipsis,
                                              style: cardcontent,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text('Balance ',
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
                                              '₹${formatDoubleIntoAmount(balance)}',
                                              overflow: TextOverflow.ellipsis,
                                              style: cardcontent,
                                            ),
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
                            ),
                          );
                        },
                      ),
              ),
              // const SizedBox(height: 85),
            ],
          ),
          Positioned(
            top: 160, // Adjust based on the space above the ListView
            left: 0,
            right: 0,
            child: Container(
                color: abs_blue,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Opening : ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${formatAmount(openingAmnt.toString())}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
      bottomSheet: commanBottomSheet(totalData),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
