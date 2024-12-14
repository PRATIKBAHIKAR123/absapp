import 'dart:convert';

import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/comman-bottomsheet.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/invoicemenulist.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/screens/register/registerform.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:abs/services/salesService.dart';
import 'package:abs/services/setupInfoService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../layouts/absdrawer.dart';
import '../../global/styles.dart';
import '../comman-widgets/invoice-dialog.dart';

class SalesInvoiceListScreen extends StatefulWidget {
  final String? fromDate;
  final String? toDate;
  const SalesInvoiceListScreen({super.key, this.fromDate, this.toDate});

  @override
  State<SalesInvoiceListScreen> createState() => _SalesInvoiceListScreen();
}

class _SalesInvoiceListScreen extends State<SalesInvoiceListScreen> {
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

  Map<String, dynamic> setupInfoData = {};

  bool isLoading = true;

  String userData = '';
  late String currentSessionId;
  List spIds = [];
  List<Map<String, dynamic>>? Invoices;
  String searchText = '';
  int? businessTypeId;
  late String fromDate;
  late String toDate;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();
  List<Map<String, String>> totalData = [
    {'Total Rows': '00'},
    {'Total Taxable Value': '00'},
    {'Grand Total ': '00'}
  ];

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
    if (widget.fromDate != null && widget.toDate != null) {
      fromDate = '${widget.fromDate!} 00:00:00';
      toDate = '${widget.toDate!} 23:59:59';
    } else {
      fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
      toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    }
    loadUserData();
    getCompanyData();
  }

  Future<void> getCompanyData() async {
    Map<String, dynamic>? currentCompany =
        await CompanyDataUtil.getCompanyFromLocalStorage();
    setState(() {
      businessTypeId = currentCompany!['businessType'];
    });
    print('businessTypeId$businessTypeId');
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

  Future<void> setuInfoData() async {
    setupInfoData = await getSetupInfoData(1, true, currentSessionId);
    spIds = setupInfoData['billingPlaces']
        .map<int>((item) => item['spId'] as int)
        .toList();
    print('spIds: $spIds');
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
        "invType": 1,
        "spIds": spIds,
        "isSync": false,
        "bill_No": null,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "text": searchText,
        "ledger_ID": null,
        "sessionId": currentSessionId
      };

      var response = await salesListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData['list']);

          isLoading = false;
          int totalRows = 0;
          double totalTaxableValue = 0;
          double grandTotal = 0;
          double profitTotal = 0;
          // Calculate totals
          for (var invoice in Invoices!) {
            totalRows++;
            totalTaxableValue += invoice['item_SubTotal'];
            grandTotal += invoice['grandTotal'];
            profitTotal += invoice['profit'];
          }

          // Update totalData
          totalData = [
            {'Total Rows': totalRows.toString()},
            {'Total Taxable Value': totalTaxableValue.toString()},
            {'Grand Total': grandTotal.toString()},
            {'Profit Total': profitTotal.toString()}
          ];
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

  void ledgerChange(String ledger) {
    print('ledger' + ledger);
    setState(() {
      searchText = ledger;
    });
    getList();
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
                    'Sales Invoice',
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
                        ////barrierColor: Colors.transparent, // No backdrop
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
              SearchLedger(
                onTextChanged: ledgerChange,
              ),
              const SizedBox(height: 15),
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
                        DateTime date = DateTime.parse(invoice['date']);
                        String formattedDate =
                            DateFormat('dd MM yyyy').format(date);
                        return GestureDetector(
                            onTap: () => {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return InvoiceDialog(
                                        sessionId: currentSessionId,
                                        id: invoice['invCode'].toString(),
                                      );
                                    },
                                  )
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
                                          '${invoice['partyName']}',
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
                                          Text('${formattedDate}',
                                              style: carddate),
                                        ],
                                      )
                                    ]),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text('Sales Bill No ',
                                              style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child:
                                              Text(':', style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            '${invoice['bill_No']}',
                                            style: cardcontent,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text('Grand Total ',
                                              style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child:
                                              Text(':', style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                              '₹${formatDoubleIntoAmount(invoice['grandTotal'])}',
                                              style: cardcontent),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                              businessTypeId == 27
                                                  ? 'Company Name'
                                                  : 'Stock Place',
                                              style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child:
                                              Text(':', style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            constraints: BoxConstraints(
                                                maxWidth:
                                                    260), // Adjust the maxWidth as needed
                                            child: Text(
                                              '${invoice['spName'] ?? ''}',
                                              style: cardcontent,
                                              overflow: TextOverflow.ellipsis,
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
                                          flex: 3,
                                          child: Text('Profit',
                                              style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child:
                                              Text(':', style: cardmaincontent),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                              '₹${formatDoubleIntoAmount(invoice['profit'])}',
                                              style: cardcontent),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTapDown: (TapDownDetails details) {
                                            showCustomPopupMenu(
                                              context: context,
                                              position: details.globalPosition,
                                              invoice: invoice,
                                              id: invoice['invCode'].toString(),
                                              invType: 1,
                                            );
                                          },
                                          child: Image.asset(
                                            'assets/icons/docdblu.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                      ],
                                    )
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
      bottomSheet: commanBottomSheet(totalData),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
