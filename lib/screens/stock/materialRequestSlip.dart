import 'dart:convert';

import 'package:abs/global/invoiceTypes.dart';
import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/comman-bottomsheet.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/invoice-dialog.dart';
import 'package:abs/screens/comman-widgets/invoicemenulist.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/screens/register/registerform.dart';
import 'package:abs/screens/reports/materialRequest.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:abs/services/reportsService.dart';
import 'package:abs/services/salesService.dart';
import 'package:abs/services/setupInfoService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../global/styles.dart';
import '../../../layouts/absdrawer.dart';

class MaterialRequestSlipScreen extends StatefulWidget {
  final InvoiceType invoiceType;
  final String? fromDate;
  final String? toDate;
  const MaterialRequestSlipScreen(
      {super.key, required this.invoiceType, this.fromDate, this.toDate});

  @override
  State<MaterialRequestSlipScreen> createState() =>
      _MaterialRequestSlipScreen();
}

class _MaterialRequestSlipScreen extends State<MaterialRequestSlipScreen>
    with SingleTickerProviderStateMixin {
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

  bool isLoading = true;

  String userData = '';
  late String currentSessionId;
  List spIds = [];
  List<Map<String, dynamic>>? Invoices;
  List<Map<String, dynamic>>? ReportsList;
  String searchText = '';
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  Map<String, dynamic> setupInfoData = {};
  late String fromDate;
  late String toDate;
  List<Map<String, String>> totalData = [
    {'Total Rows': '00'},
    {'Total Taxable Value': '00'},
    {'Grand Total ': '00'}
  ];
  int? invoice_type;
  String ladgerLabel = '';
  String billNoLabel = '';
  int? ledgerId;
  int? businessTypeId;
  late TabController _tabController;

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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int _currentTabIndex = _tabController.index; // Update current tab index

        // Perform actions based on the current tab index
        if (_currentTabIndex == 0) {
          getList();
        } else if (_currentTabIndex == 1) {
          getDocReportList();
        }
      }
    });
    invoice_type = widget.invoiceType.id;
    getCompanyData();
    print('list invoice type:${widget.invoiceType}');
    if (widget.fromDate != null && widget.toDate != null) {
      fromDate = '${widget.fromDate!} 00:00:00';
      toDate = '${widget.toDate!} 23:59:59';
    } else {
      fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
      toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    }

    resolveValuesForType(widget.invoiceType, ActionType.list);
    loadUserData();
  }

  void resolveValuesForType(InvoiceType type, ActionType action) {
    ladgerLabel = type.getLedgerLabel();
    billNoLabel = type.getBillNoLabel();

    print('ladgerLabel$billNoLabel');
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
    setupInfoData =
        await getSetupInfoData(invoice_type, true, currentSessionId);
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
        "invType": invoice_type,
        "spIds": spIds,
        "isSync": false,
        "bill_No": null,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "text": searchText,
        "ledger_ID": ledgerId,
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

  getDocReportList() async {
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
        "invType": invoice_type,
        "invoiceNo": null,
        "isActual": true,
        "isAdvance": false,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "itemDetails": false,
        "itemId": null,
        "ledgerId": null,
        "reportOptions": "3",
        "ledger_ID": null,
        "sessionId": currentSessionId
      };

      var response = await documentReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          ReportsList = List<Map<String, dynamic>>.from(decodedData);

          isLoading = false;
          int totalRows = 0;
          double grandTotal = 0;

          // Calculate totals
          for (var invoice in ReportsList!) {
            totalRows++;
            grandTotal += invoice['Std_Qty'];
          }

          // Update totalData
          totalData = [
            {'Total Rows': totalRows.toString()},
            {'Qty': grandTotal.toString()}
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

  void ledgerSelects(Map<String, dynamic> ledger) {
    print('ledger$ledger');
    setState(() {
      searchText = '';
      ledgerId = ledger['id'];
    });
    getList();
  }

  String getInvoiceDescription(InvoiceType invoiceType) {
    return InvoiceVoucherTypesObjByte[invoiceType] ?? 'Unknown Invoice Type';
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
                  Text(
                    getInvoiceDescription(widget.invoiceType),
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
                                  initialFromDate:
                                      fromDate, // Example initial from date
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
                onledgerSelects: ledgerSelects,
              ),
              const SizedBox(height: 2),
              // Add TabBar here
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: Text('Main')),
                  Tab(icon: Text('With Item Summary')),
                ],
                labelColor: abs_blue,
                unselectedLabelColor: Colors.grey,
              ),
              const SizedBox(height: 15),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context)
                          .size
                          .height, // Specify a height for the TabBarView
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [main(), withItemSummary()],
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: invoice_type != 2
          ? Container(
              margin: EdgeInsets.only(bottom: 120),
              child: FloatingActionButton(
                  backgroundColor: abs_blue,
                  onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MaterialRequestScreen(
                                    rid: 0,
                                    invoiceType: widget.invoiceType,
                                  )),
                        )
                      },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  )))
          : Container(),
      bottomSheet: materialBottomSheet(context, totalData),
      // bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget main() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 111),
      itemCount: Invoices?.length ?? 0,
      itemBuilder: (context, index) {
        if (Invoices == null || Invoices!.isEmpty) {
          return Center(
            child: Text('No invoices found'),
          );
        }
        var invoice = Invoices![index];
        DateTime date = DateTime.parse(invoice['date']);
        String formattedDate = DateFormat('dd MM yyyy').format(date);
        return GestureDetector(
            onTap: () => {
                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return InvoiceDialog(
                  //       sessionId: currentSessionId,
                  //       id: invoice['invCode'].toString(),
                  //       invoice: invoice,
                  //       invoiceType: widget.invoiceType,
                  //     );
                  //   },
                  // )
                },
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.white,
              child: ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text('${formattedDate}', style: carddate),
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
                          child: Text('$billNoLabel ', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':', style: cardmaincontent),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Grand Total ', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':', style: cardmaincontent),
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
                      mainAxisAlignment: MainAxisAlignment.start,
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
                          child: Text(':', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth: 260), // Adjust the maxWidth as needed
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Profit', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':', style: cardmaincontent),
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
                          child: Image.asset(
                            'assets/icons/docdblu.png',
                            height: 20,
                          ),
                          onTapDown: (TapDownDetails details) {
                            showCustomPopupMenu(
                              context: context,
                              position: details.globalPosition,
                              invoice: invoice,
                              id: invoice['invCode'].toString(),
                              invType: invoice_type,
                              invoiceType: widget.invoiceType,
                            );
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          child: Image.asset(
                            'assets/icons/edit.png',
                            height: 20,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MaterialRequestScreen(
                                        rid: invoice['invCode'],
                                        invoiceType: widget.invoiceType,
                                      )),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            ));
      },
    );
  }

  Widget withItemSummary() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(bottom: 111),
      itemCount: ReportsList?.length ?? 0,
      itemBuilder: (context, index) {
        if (ReportsList == null || ReportsList!.isEmpty) {
          return Center(
            child: Text('No invoices found'),
          );
        }
        var invoice = ReportsList![index];
        return GestureDetector(
            onTap: () => {
                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     return InvoiceDialog(
                  //       sessionId: currentSessionId,
                  //       id: invoice['invCode'].toString(),
                  //       invoice: invoice,
                  //       invoiceType: widget.invoiceType,
                  //     );
                  //   },
                  // )
                },
            child: Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: Colors.white,
              child: ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${invoice['Itemcode'] ?? ''}',
                          style: cardHeader,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Item Name ', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            '${invoice['Itemname'] ?? ''}',
                            style: cardcontent,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Category', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text('${invoice['Category'] ?? ''}',
                              style: cardcontent),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text('Qty', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(':', style: cardmaincontent),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth: 260), // Adjust the maxWidth as needed
                            child: Text(
                              '${invoice['Std_Qty'] ?? ''}',
                              style: cardcontent,
                              overflow: TextOverflow.ellipsis,
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
    );
  }
}

Widget materialBottomSheet(context, List<Map<String, String>> totalData) {
  const TextStyle cardcontent = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
  );

  return ConstrainedBox(
    constraints: BoxConstraints(
        maxHeight: 200, // Set a maximum height for the container
        minWidth: MediaQuery.of(context).size.width),
    child: Container(
      width: double.infinity,
      color: abs_blue,
      padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: totalData.map((data) {
            final String key = data.keys.first;
            final String value = data.values.first;
            final formattedValue = formatAmount(value);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$key :', style: cardcontent),
                  SizedBox(
                      width: 5), // Add some space between the key and value
                  if (key == 'Total Rows')
                    Text('$formattedValue', style: cardcontent),
                  if (key != 'Total Rows')
                    Text(key == 'Qty' ? '$value' : '₹$formattedValue',
                        style: cardcontent),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
