import 'dart:convert';

import 'package:abs/global/invoiceTypes.dart';
import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/sales/salesenquiry/salesEnquiryList.dart';
import 'package:abs/screens/sales/salesorder/salesOrderList.dart';
import 'package:abs/screens/sales/salesquotation/salesQuotionList.dart';
import 'package:abs/screens/salesinvoice/salesInvoiceList.dart';
import 'package:abs/screens/stock/materialRequestSlip.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:abs/services/dashboardService.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/reportsService.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/styles.dart';
import '../../layouts/absappbar.dart';
import '../../layouts/absdrawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen> {
  final TextStyle urbanistTextStyle = GoogleFonts.urbanist(
    fontSize: 30,
    color: const Color(0xFF00AFEF),
    fontWeight: FontWeight.w700,
  );

  final TextStyle DashboardCardTextStyle = const TextStyle(
    fontSize: 14,
    color: Color.fromRGBO(0, 176, 232, 1),
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
  );

  final TextStyle dateStyle = const TextStyle(
    fontSize: 14,
    color: abs_grey,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle dateStyle2 = const TextStyle(
    fontSize: 14,
    color: abs_blue,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle statHeader = const TextStyle(
    fontSize: 18,
    color: abs_grey,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle cardHeader = const TextStyle(
    fontSize: 18,
    color: abs_blue,
    fontFamily: 'Urbanist',
    fontWeight: FontWeight.w500,
  );

  final TextStyle stockHeader = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontFamily: 'Urbanist',
    fontWeight: FontWeight.w500,
  );

  final TextStyle cardmaincontent = const TextStyle(
    fontSize: 12,
    color: Color.fromRGBO(0, 0, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );
  final TextStyle cardsubcontent = const TextStyle(
    fontSize: 12,
    color: abs_blue,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );
  final List<String> iconNames = [
    'sales',
    'purchase',
    'outstanding',
    'bank',
    'expenses',
    'accounts',
  ];

  final List<String> menuNames = [
    'Sales',
    'Purchase',
    'Outstanding',
    'Cash/Bank',
    'Expense/Income',
    'Stock'
  ];

  List<Map<String, dynamic>> quickLinks = [
    {'id': '1', 'name': 'Sales', 'iconName': 'sales'},
    {'id': '2', 'name': 'Purchase', 'iconName': 'purchase'},
    {'id': '3', 'name': 'Stock', 'iconName': 'stockicon'},
    {'id': '5', 'name': 'Account', 'iconName': 'accountsicon'},
  ];

  bool isLoading = true;

  String userData = '';
  late String currentSessionId;
  List spIds = [0, 1, 2, 3, 4, 5, 6, 7];
  List<Map<String, dynamic>>? salesStats;
  List<Map<String, dynamic>>? purchaseStats;
  List<Map<String, dynamic>>? Stats;
  String searchText = '';

  late String fromDate;
  late String toDate;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  String activequickLink = '1';
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController fromDatecontroller = TextEditingController();
  TextEditingController toDatecontroller = TextEditingController();
  final List<Map<String, dynamic>> enSPReportSearchBy = [
    {'text': 'All Stock', 'id': 1},
    {'text': 'Category', 'id': 2},
    {'text': 'Brand', 'id': 3},
    {'text': 'Group', 'id': 4},
  ];
  List<Map<String, dynamic>> stockValue = [];
  Map<String, dynamic> allStockValue = {};
  Map<String, dynamic> allSalesStockValue = {};
  Map<String, dynamic> allPurchaseStockValue = {};
  List<Map<String, dynamic>> selectedStockPlaceObjects = [];
  int? _selectedSPReportSearchById = 1;
  String? purchaseStockType = 'All Stock';
  String? salesStockType = 'All Stock';
  List<Map<String, dynamic>> stockPlaceList = [];
  int? businessTypeId;
  List<Map<String, dynamic>> salesProCategoryMargin = [
    {
      'itemName': 'Cloth',
      'openingQty': 1000,
      'openingValue': 400.0,
      'closingQty': 1000,
      'closingValue': 400.0,
    },
    {
      'itemName': 'Cosmetic',
      'openingQty': 500,
      'openingValue': 400.0,
      'closingQty': 500,
      'closingValue': 400.0,
    },
  ];

  List<Map<String, dynamic>> salesProGroupMargin = [
    {
      'itemName': 'Fabric',
      'openingQty': 1000,
      'openingValue': 400.0,
      'closingQty': 1000,
      'closingValue': 400.0,
    },
    {
      'itemName': 'Fashion',
      'openingQty': 500,
      'openingValue': 400.0,
      'closingQty': 500,
      'closingValue': 400.0,
    },
  ];

  List<Map<String, dynamic>> salesProBrandMargin = [
    {
      'itemName': 'Arrow',
      'openingQty': 1000,
      'openingValue': 400.0,
      'closingQty': 1000,
      'closingValue': 400.0,
    },
    {
      'itemName': 'Lakme',
      'openingQty': 500,
      'openingValue': 400.0,
      'closingQty': 500,
      'closingValue': 400.0,
    },
  ];

  List<Map<String, dynamic>> accounts = [
    {
      'TypeName': 'Outstanding',
      'col1Value1': 1000,
      'colValue2': 400.0,
      'col1': 'Customer',
      'col2Val1': 500,
      'col2Val2': 400.0,
      'col2': 'Supplier',
    },
    {
      'TypeName': 'Cash / Bank ',
      'col1Value1': 1000,
      'colValue2': 400.0,
      'col1': 'Cash In Hand',
      'col2Val1': 500,
      'col2Val2': 400.0,
      'col2': 'Banks',
    },
    {
      'TypeName': 'Expenses / Income ',
      'col1Value1': 1000,
      'colValue2': 400.0,
      'col1': 'Total Expense',
      'col2Val1': 500,
      'col2Val2': 400.0,
      'col2': 'Total Income',
    },
    {
      'TypeName': 'Sales / Purchase ',
      'col1Value1': 1000,
      'colValue2': 400.0,
      'col1': 'Sales',
      'col2Val1': 500,
      'col2Val2': 400.0,
      'col2': 'Purchase',
    },
    {
      'TypeName': 'Profit / Loss ',
      'col1Value1': 1000,
      'colValue2': 400.0,
      'col1': 'Gross',
      'col2Val1': 500,
      'col2Val2': 400.0,
      'col2': 'Net',
    },
    {
      'TypeName': 'Current Assest / Liability',
      'col1Value1': 1000,
      'colValue2': 400.0,
      'col1': 'Assets',
      'col2Val1': 500,
      'col2Val2': 400.0,
      'col2': 'Liability',
    },
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
    fromDate = DateFormat('dd/MM/yyyy').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    fromDatecontroller.text = fromDate;
    toDatecontroller.text = toDate;
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
    if (businessTypeId == 27) {
      quickLinks = [
        {'id': '2', 'name': 'Purchase', 'iconName': 'purchase'},
        {'id': '3', 'name': 'Stock', 'iconName': 'stockicon'},
      ];
      activequickLink = '2';
    }
    if (businessTypeId == 31 || businessTypeId == 3) {
      quickLinks = [
        {'id': '1', 'name': 'Sales', 'iconName': 'sales'},
      ];
      activequickLink = '1';
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
          getStockPlaces();
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

  void _onQuickLinkTapped(String id) {
    setState(() {
      activequickLink = id;
    });
    print(id);
    switch (id) {
      case '1':
        {
          getList();
        }
        break;
      case '2':
        {
          getList();
        }
        break;
      case '3':
        {
          getAllStockValues();
          getSalesOrdersList();
          getPurchaseOrdersList();
        }
        break;
      case '4':
        {}
        break;
    }
  }

  getStockPlaces() async {
    try {
      var requestBody = {"table": 4, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          stockPlaceList = List<Map<String, dynamic>>.from(decodedData);
          selectedStockPlaceObjects = stockPlaceList;
          if (businessTypeId == 27) {
            selectedStockPlaceObjects =
                stockPlaceList.where(((test) => test['id'] != 0)).toList();
          }
          stockPlaceList = selectedStockPlaceObjects;
          spIds = selectedStockPlaceObjects
              .map<int>((item) => item['id'] as int)
              .toList();
          print('stockPlaceList$stockPlaceList');
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

  getStockValues() async {
    try {
      var requestBody = {
        "dashboardSource": null,
        "subSource": 0,
        "itemCol": _selectedSPReportSearchById.toString(),
        "fromDate": null,
        "toDate": null,
        "spIds": selectedStockPlaceObjects,
        "itemSearchBy": _selectedSPReportSearchById.toString(),
        "spId": null,
        "sessionId": currentSessionId
      };

      var response = await reportStockValueService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          stockValue = List<Map<String, dynamic>>.from(decodedData);
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

  getAllStockValues() async {
    try {
      var requestBody = {
        "dashboardSource": null,
        "subSource": 0,
        "itemCol": 1,
        "fromDate": "2024-08-01",
        "toDate": "2024-08-23",
        "spIds": selectedStockPlaceObjects,
        "itemSearchBy": 1,
        "spId": 0,
        "sessionId": currentSessionId
      };

      var response = await reportStockValueService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          List<Map<String, dynamic>> stockValue_ =
              List<Map<String, dynamic>>.from(decodedData);
          allStockValue = stockValue_.first;
          print('allStockValue$allStockValue');
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

  getList() async {
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy').parse(toDate);

    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "dashboardSource": int.parse(activequickLink),
        "subSource": 0,
        "itemCol": null,
        "fromDate": formattedFromDate,
        "toDate": formattedToDate,
        "spIds": spIds,
        "itemSearchBy": null,
        "sessionId": currentSessionId
      };

      var response = await salesStatsService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Stats = List<Map<String, dynamic>>.from(decodedData);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  getSalesOrdersList() async {
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy').parse(toDate);

    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "dashboardSource": int.parse(activequickLink),
        "subSource": 1,
        "itemCol": salesStockType,
        "fromDate": salesStockType == 'All Stock' ? formattedFromDate : null,
        "toDate": salesStockType == 'All Stock' ? formattedToDate : null,
        "spIds": spIds,
        "itemSearchBy": salesStockType,
        "sessionId": currentSessionId
      };

      var response = await salesStatsService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          salesStats = List<Map<String, dynamic>>.from(decodedData);
          if (salesStockType == 'All Stock') {
            allSalesStockValue = decodedData.first;
          }

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  getPurchaseOrdersList() async {
    DateTime parsedFromDate = DateFormat('dd/MM/yyyy').parse(fromDate);
    DateTime parsedToDate = DateFormat('dd/MM/yyyy').parse(toDate);

    String formattedFromDate =
        DateFormat('dd/MM/yyyy 00:00:00').format(parsedFromDate);
    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "dashboardSource": int.parse(activequickLink),
        "subSource": 2,
        "itemCol": purchaseStockType,
        "fromDate": purchaseStockType == 'All Stock' ? formattedFromDate : null,
        "toDate": purchaseStockType == 'All Stock' ? formattedToDate : null,
        "spIds": spIds,
        "itemSearchBy": purchaseStockType,
        "sessionId": currentSessionId
      };

      var response = await salesStatsService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          purchaseStats = List<Map<String, dynamic>>.from(decodedData);
          if (purchaseStockType == 'All Stock') {
            allPurchaseStockValue = decodedData.first;
          }

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
      setState(() {
        isLoading = false;
      });
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
      fromDatecontroller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      fromDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
    getList(); // Call getList after updating the date
  }

  onTapToDateFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (pickedDate == null) return;

    setState(() {
      toDatecontroller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      toDate = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
    getList(); // Call getList after updating the date
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: quickLinks
                      .length, // Adjusted to use the length of quickLinks
                  itemBuilder: (context, index) {
                    final link =
                        quickLinks[index]; // Accessing each map in the list

                    return GestureDetector(
                      onTap: () {
                        _onQuickLinkTapped(
                            link['id']); // Using the 'id' from the current map
                      },
                      child: Container(
                        padding: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 229, 241, 249),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: activequickLink == link['id']
                                    ? abs_blue
                                    : Colors.transparent)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/${link['iconName']}.png', // Accessing 'iconName' from the current map
                              height: 29,
                              width: 29,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              link[
                                  'name'], // Accessing 'name' from the current map
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: abs_blue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // const SizedBox(height: 20),
                // // const Text(
                // //   'Quick Links',
                // //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // // ),
                // // const SizedBox(height: 10),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: quickLinks.map((link) {
                //       return Padding(
                //           padding: const EdgeInsets.only(right: 10),
                //           child: GestureDetector(
                //             onTap: () => {_onQuickLinkTapped(link['id'])},
                //             child: Chip(
                //               label: Text(link['name']),
                //               side: BorderSide.none,
                //               shape: const RoundedRectangleBorder(
                //                   borderRadius:
                //                       BorderRadius.all(Radius.circular(24))),
                //               backgroundColor: link['id'] == '$activequickLink'
                //                   ? abs_blue
                //                   : Colors.grey[300],
                //               labelStyle: TextStyle(
                //                 color: link['id'] == '$activequickLink'
                //                     ? Colors.white
                //                     : Colors.black,
                //               ),
                //             ),
                //           ));
                //     }).toList(),
                //   ),
                // ),

                const SizedBox(height: 20),
                const Text(
                  'Quick Stats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  child: DropdownSearch<Map<String, dynamic>>.multiSelection(
                    items: stockPlaceList,
                    itemAsString: (Map<String, dynamic> item) =>
                        item['name'].toString(),
                    popupProps: PopupPropsMultiSelection.menu(
                      showSelectedItems: false,
                    ),
                    dropdownBuilder:
                        (context, List<Map<String, dynamic>> selectedItems) {
                      if (selectedItems.length > 5) {
                        return Text('${selectedItems.length} items selected');
                      } else if (selectedItems.isEmpty) {
                        return Text(businessTypeId == 27
                            ? 'Select Company Name'
                            : 'Select stock place');
                      } else {
                        return Text(selectedItems
                            .map((item) => item['name'])
                            .join(', '));
                      }
                    },
                    onChanged: (List<Map<String, dynamic>> selectedItems) {
                      setState(() {
                        selectedStockPlaceObjects = selectedItems;
                        spIds = selectedItems
                            .map<int>((item) => item['id'] as int)
                            .toList();
                      });
                      print(selectedStockPlaceObjects);
                      getList();
                      _onQuickLinkTapped(activequickLink);
                    },
                    selectedItems: selectedStockPlaceObjects,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: fromDatecontroller,
                        decoration: InputDecoration(
                            constraints: BoxConstraints(minHeight: 6),
                            hintText: 'From',
                            border: borderStyle),
                        onTap: () => onTapFunction(context: context),
                      ),
                    ),
                    SizedBox(width: 16), // Add spacing between the text fields
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: toDatecontroller,
                        decoration: InputDecoration(
                            hintText: 'To', border: borderStyle),
                        onTap: () => onTapToDateFunction(context: context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (activequickLink == '1' || activequickLink == '2')
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: Stats?.length ?? 0,
                          itemBuilder: (context, index) {
                            if (Stats == null || Stats!.isEmpty) {
                              return Center(
                                child: Text('No Stats found'),
                              );
                            }
                            var stat = Stats![index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.white,
                              child: ListTile(
                                onTap: () {
                                  if (stat['INV_TYPE'] == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SalesInvoiceListScreen(
                                                fromDate: fromDate,
                                                toDate: toDate,
                                              )),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MaterialRequestSlipScreen(
                                                invoiceType:
                                                    InvoiceTypeExtension.fromId(
                                                        stat['INV_TYPE']),
                                                fromDate: fromDate,
                                                toDate: toDate,
                                              )),
                                    );
                                  }
                                },
                                title: Row(children: [
                                  Text(
                                    '${stat['TypeName'].split(' ').first} / ',
                                    style: statHeader,
                                  ),
                                  Text(
                                    '${stat['TypeName']}',
                                    style: cardHeader,
                                  )
                                ]),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    // Row(
                                    //   children: [
                                    //     Image.asset(
                                    //       'assets/icons/calendar.png',
                                    //       height: 16,
                                    //       width: 16,
                                    //     ),
                                    //     const SizedBox(width: 5),
                                    //     Text(
                                    //       '01/01/2024',
                                    //       style: dateStyle,
                                    //     ),
                                    //     const SizedBox(width: 20),
                                    //     Image.asset(
                                    //       'assets/icons/arrow.png',
                                    //       height: 14,
                                    //       width: 59,
                                    //     ),
                                    //     const SizedBox(width: 20),
                                    //     Image.asset(
                                    //       'assets/icons/calendar-1.png',
                                    //       height: 16,
                                    //       width: 16,
                                    //     ),
                                    //     const SizedBox(width: 10),
                                    //     Text('01/02/2024', style: dateStyle2),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 5),
                                    if (stat['Total'] != null &&
                                        stat['Total'] != "")
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child:
                                                Text('Total', style: dateStyle),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(':', style: dateStyle),
                                          ),
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      260), // Adjust the maxWidth as needed
                                              child: Text(
                                                  '₹${formatDoubleIntoAmount(stat['Total'])}',
                                                  style: dateStyle2),
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
                                          flex: 1,
                                          child: Text('No', style: dateStyle),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(':', style: dateStyle),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                            constraints: BoxConstraints(
                                                maxWidth:
                                                    260), // Adjust the maxWidth as needed
                                            child: Text('${stat['TotalNo']}',
                                                style: dateStyle2),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                if (activequickLink == '3')
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor:
                          Colors.transparent, // Customize divider color
                      dividerTheme: DividerThemeData(
                        color: Colors.blue, // Customize divider color
                        space: 0, // Adjust space if needed
                        thickness: 1, // Adjust thickness if needed
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: abs_blue),
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "Product",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                      child: DropdownButtonFormField<int>(
                                        value: _selectedSPReportSearchById,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Select Option',
                                        ),
                                        items: enSPReportSearchBy.map((item) {
                                          return DropdownMenuItem<int>(
                                            value: item['id'] as int?,
                                            child: Text(item['text'] as String),
                                          );
                                        }).toList(),
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            _selectedSPReportSearchById =
                                                newValue;
                                            getStockValues();
                                            getAllStockValues();
                                          });
                                        },
                                      ),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      color: Colors.white,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(7),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text('Open Stock',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(':',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: FittedBox(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    // Ensure the text fits within the container
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${allStockValue['OpenStock']}',
                                                      style: cardsubcontent,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
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
                                                  child: Text(
                                                      'Open Stock Value',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(':',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: FittedBox(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      // Ensure the text fits within the container
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        '₹${formatDoubleIntoAmount(allStockValue['OpenStockValue'])}',
                                                        style: cardsubcontent,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )),
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
                                                  child: Text('Bal Stock ',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(':',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: FittedBox(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    // Ensure the text fits within the container
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${allStockValue['BalStock']}',
                                                      style: cardsubcontent,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
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
                                                  child: Text('Bal Stock Value',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(':',
                                                      style: cardmaincontent),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: FittedBox(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    // Ensure the text fits within the container
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '₹${formatDoubleIntoAmount(allStockValue['BalStockValue'])}',
                                                      style: cardsubcontent,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                      ),
                                    ),
                                    ListView.builder(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: stockValue?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        if (stockValue == null ||
                                            stockValue!.isEmpty) {
                                          return Center(
                                            child: Text('No invoices found'),
                                          );
                                        }
                                        var invoice = stockValue![index];
                                        String ledger = '';
                                        String dataBy = '';
                                        if (_selectedSPReportSearchById == 1) {
                                          dataBy = '';
                                        }
                                        if (_selectedSPReportSearchById == 2) {
                                          dataBy = 'Category';
                                        }
                                        if (_selectedSPReportSearchById == 3) {
                                          dataBy = 'Brand';
                                        }
                                        if (_selectedSPReportSearchById == 4) {
                                          dataBy = 'ItemGroup';
                                        }
                                        if (invoice['$dataBy'] != null) {
                                          ledger = invoice['$dataBy'];
                                        }

                                        return Card(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          color: Colors.white,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(7),
                                            title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${ledger}',
                                                      style: stockHeader,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ]),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text('Open Stock',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(':',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: FittedBox(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['OpenStock']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
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
                                                      child: Text(
                                                          'Open Stock Value',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(':',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: FittedBox(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '₹${formatDoubleIntoAmount(invoice['OpenStockValue'])}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
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
                                                      child: Text('Bal Stock ',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(':',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: FittedBox(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['BalStock']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
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
                                                      child: Text(
                                                          'Bal Stock Value',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(':',
                                                          style:
                                                              cardmaincontent),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: FittedBox(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '₹${formatDoubleIntoAmount(invoice['BalStockValue'])}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            isThreeLine: true,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: abs_blue),
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "Sales Product",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            children: <Widget>[
                              ExpansionTile(
                                title: Text(
                                  'Sales Product Category Profit Margin',
                                  style: cardHeader,
                                ),
                                children: <Widget>[
                                  ListView.builder(
                                    padding: EdgeInsets.all(10),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        salesProCategoryMargin?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      if (salesProCategoryMargin == null ||
                                          salesProCategoryMargin!.isEmpty) {
                                        return Center(
                                          child: Text('No Details found'),
                                        );
                                      }
                                      var invoice =
                                          salesProCategoryMargin![index];
                                      String ledger = '';

                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        color: Colors.white,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(7),
                                          title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${invoice['itemName']}',
                                                    style: stockHeader,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ]),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Opening Qty:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['openingQty']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text('Opening Value:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '₹${formatDoubleIntoAmount(invoice['openingValue'])}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Closing Qty :',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['closingQty']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text('Closing Value:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '₹${formatDoubleIntoAmount(invoice['closingValue'])}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          isThreeLine: true,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text(
                                  'Sales Product Brand Profit Margin',
                                  style: cardHeader,
                                ),
                                children: <Widget>[
                                  ListView.builder(
                                    padding: EdgeInsets.all(10),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: salesProBrandMargin?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      if (salesProBrandMargin == null ||
                                          salesProBrandMargin!.isEmpty) {
                                        return Center(
                                          child: Text('No Details found'),
                                        );
                                      }
                                      var invoice = salesProBrandMargin![index];
                                      String ledger = '';

                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        color: Colors.white,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(7),
                                          title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${invoice['itemName']}',
                                                    style: stockHeader,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ]),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Opening Qty:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['openingQty']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text('Opening Value:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '₹${formatDoubleIntoAmount(invoice['openingValue'])}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Closing Qty :',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['closingQty']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text('Closing Value:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '₹${formatDoubleIntoAmount(invoice['closingValue'])}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          isThreeLine: true,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text(
                                  'Sales Product Group Profit Margin',
                                  style: cardHeader,
                                ),
                                children: <Widget>[
                                  ListView.builder(
                                    padding: EdgeInsets.all(10),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: salesProGroupMargin?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      if (salesProGroupMargin == null ||
                                          salesProGroupMargin!.isEmpty) {
                                        return Center(
                                          child: Text('No Details found'),
                                        );
                                      }
                                      var invoice = salesProGroupMargin![index];
                                      String ledger = '';

                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        color: Colors.white,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(7),
                                          title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '${invoice['itemName']}',
                                                    style: stockHeader,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ]),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Opening Qty:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['openingQty']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text('Opening Value:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '₹${formatDoubleIntoAmount(invoice['openingValue'])}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text('Closing Qty :',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '${invoice['closingQty']}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text('Closing Value:',
                                                          style:
                                                              cardmaincontent),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '₹${formatDoubleIntoAmount(invoice['closingValue'])}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          isThreeLine: true,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: abs_blue),
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "Sales Order",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                      child: DropdownButtonFormField<String>(
                                        value: salesStockType,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Select Option',
                                        ),
                                        items: enSPReportSearchBy.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item['text'] as String?,
                                            child: Text(item['text'] as String),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            salesStockType = newValue;
                                            getSalesOrdersList();
                                          });
                                        },
                                      ),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      color: Colors.white,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(7),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Quantity:',
                                                        style: cardmaincontent),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    FittedBox(
                                                      // Ensure the text fits within the container
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        '${allSalesStockValue['QTY']}',
                                                        style: cardsubcontent,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text('Pending:',
                                                        style: cardmaincontent),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    FittedBox(
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '₹${formatDoubleIntoAmount(allSalesStockValue['Pending'])}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                      ),
                                    ),
                                    ListView.builder(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: salesStats?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        if (salesStats == null ||
                                            salesStats!.isEmpty) {
                                          return Center(
                                            child: Text('No invoices found'),
                                          );
                                        }
                                        var invoice = salesStats![index];
                                        String ledger = '';

                                        if (invoice['ItemCol'] != null) {
                                          ledger = invoice['ItemCol'];
                                        }

                                        return Card(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          color: Colors.white,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(7),
                                            title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${ledger}',
                                                      style: stockHeader,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ]),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Quantity:',
                                                            style:
                                                                cardmaincontent),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '${invoice['QTY']}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Text('Pending:',
                                                            style:
                                                                cardmaincontent),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        FittedBox(
                                                            // Ensure the text fits within the container
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              '₹${formatDoubleIntoAmount(invoice['Pending'])}',
                                                              style:
                                                                  cardsubcontent,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                            isThreeLine: true,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: abs_blue),
                              borderRadius: BorderRadius.circular(10)),
                          child: ExpansionTile(
                            title: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "Purchase Order",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Container(
                                      child: DropdownButtonFormField<String>(
                                        value: purchaseStockType,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Select Option',
                                        ),
                                        items: enSPReportSearchBy.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item['text'] as String?,
                                            child: Text(item['text'] as String),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            purchaseStockType = newValue;
                                            getPurchaseOrdersList();
                                          });
                                        },
                                      ),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      color: Colors.white,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(7),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Quantity:',
                                                        style: cardmaincontent),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    FittedBox(
                                                      // Ensure the text fits within the container
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        '${allPurchaseStockValue['QTY']}',
                                                        style: cardsubcontent,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text('Pending:',
                                                        style: cardmaincontent),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    FittedBox(
                                                        // Ensure the text fits within the container
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          '₹${formatDoubleIntoAmount(allPurchaseStockValue['Pending'])}',
                                                          style: cardsubcontent,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                      ),
                                    ),
                                    ListView.builder(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: purchaseStats?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        if (purchaseStats == null ||
                                            purchaseStats!.isEmpty) {
                                          return Center(
                                            child: Text('No invoices found'),
                                          );
                                        }
                                        var invoice = purchaseStats![index];
                                        String ledger = '';

                                        if (invoice['ItemCol'] != null) {
                                          ledger = invoice['ItemCol'];
                                        }

                                        return Card(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          color: Colors.white,
                                          child: ListTile(
                                            contentPadding: EdgeInsets.all(7),
                                            title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${ledger}',
                                                      style: stockHeader,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ]),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text('Quantity:',
                                                            style:
                                                                cardmaincontent),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        FittedBox(
                                                          // Ensure the text fits within the container
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '${invoice['QTY']}',
                                                            style:
                                                                cardsubcontent,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Text('Pending:',
                                                            style:
                                                                cardmaincontent),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        FittedBox(
                                                            // Ensure the text fits within the container
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child: Text(
                                                              '₹${formatDoubleIntoAmount(invoice['Pending'])}',
                                                              style:
                                                                  cardsubcontent,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                            isThreeLine: true,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (activequickLink == '5')
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accounts?.length ?? 0,
                    itemBuilder: (context, index) {
                      if (accounts == null || accounts!.isEmpty) {
                        return Center(
                          child: Text('No Stats found'),
                        );
                      }
                      var stat = accounts![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.white,
                        child: ListTile(
                          title: Row(children: [
                            Text(
                              '${stat['TypeName']}',
                              style: cardHeader,
                            )
                          ]),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${stat['col1']}:', style: dateStyle),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      '₹${formatDoubleIntoAmount(stat['col1Value1'])}',
                                      style: dateStyle2),
                                  Text(
                                      '₹${formatDoubleIntoAmount(stat['colValue2'])}',
                                      style: dateStyle2),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${stat['col2']}:', style: dateStyle),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      '₹${formatDoubleIntoAmount(stat['col2Val1'])}',
                                      style: dateStyle2),
                                  Text(
                                      '₹${formatDoubleIntoAmount(stat['col2Val2'])}',
                                      style: dateStyle2),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavigationBar());
  }
}
