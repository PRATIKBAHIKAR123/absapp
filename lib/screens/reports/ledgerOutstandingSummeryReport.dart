import 'dart:convert';

import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/comman-bottomsheet.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/screens/reports/ledgerOutSummaryFilterPopup.dart';
import 'package:abs/services/ledgerService.dart';
import 'package:abs/services/reportsService.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../global/styles.dart';
import '../../../layouts/absdrawer.dart';
import '../comman-widgets/invoice-dialog.dart';

class LedgerOutstandingSummaryScreen extends StatefulWidget {
  const LedgerOutstandingSummaryScreen({super.key});

  @override
  State<LedgerOutstandingSummaryScreen> createState() =>
      _LedgerOutstandingSummaryScreen();
}

class _LedgerOutstandingSummaryScreen
    extends State<LedgerOutstandingSummaryScreen>
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

  final TextStyle crAmnt = const TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(229, 96, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final GlobalKey<SearchLedgerState> _searchLedgerKey =
      GlobalKey<SearchLedgerState>();

  bool isLoading = false;

  String userData = '';
  late String currentSessionId;
  List spIds = [0, 1, 2, 3, 4, 5, 6, 7];
  List<Map<String, dynamic>>? Invoices;
  List<Map<String, dynamic>>? ledgers;
  String searchText = '';
  int? ledgerid;
  List<Map<String, String>> totalData = [
    {'Total Rows': '00'},
    {'Total Pending Amount': '00'},
  ];

  Map<String, dynamic> ledgerFilter = {
    "groups": [],
    "includeChildGroups": true,
    "lockFreeze": false
  };
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();

  late String fromDate;
  late String toDate;
  int? groupID;
  int? groupRadID;
  List<int> selectedLedgerIds = [];
  late TabController _tabController;
  int _currentTabIndex = 0;
  final _ledgerController = TextEditingController();
  int? _selectedGroupId;
  bool selectAll = false;
  late PageController _pageController;

  List<Map<String, dynamic>> groupradios = [
    {'id': 17, 'name': 'Customer'},
    {'id': 16, 'name': 'Supplier'},
  ];

  void updateDates(int? groupid, String to) {
    setState(() {
      groupID = groupid;
      toDate = to;
    });

    print('ledgerFilter$ledgerFilter');
    getList();
  }

  void _handleRadioValueChange(int? value) {
    setState(() {
      _selectedGroupId = value!;
      // Navigate to the second tab
    });
    onLedgerSearch(_ledgerController.text);
  }

  void _handleCheckboxChange(bool? value, int ledgerId) {
    setState(() {
      if (value == true) {
        selectedLedgerIds.add(ledgerId);
      } else {
        selectedLedgerIds.remove(ledgerId);
      }
    });
  }

  void toggleSelectAll() {
    setState(() {
      if (selectAll) {
        // If currently selecting all, clear the selected IDs
        selectedLedgerIds.clear();
      } else {
        // If not selecting all, add all ledger IDs to selectedLedgerIds
        selectedLedgerIds.addAll(
          ledgers!.map((ledger) => ledger['ledger_id'] as int).toList(),
        );
      }
      // Toggle the selectAll flag
      selectAll = !selectAll;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: _currentTabIndex);
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(lastDayOfMonth);
    loadUserData();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index; // Update current tab index
        });
        // Perform actions based on the current tab index
        if (_currentTabIndex == 0) {
          setState(() {
            selectedLedgerIds.clear();
            selectAll = false;
          });

          print("Switched to Tab 1 $selectedLedgerIds");
        } else if (_currentTabIndex == 1) {}
      }
    });
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
        "ledgers": selectedLedgerIds,
        "detailed": false,
        "includeChild": false,
        "allReceipts": false,
        "allPayments": false,
        "minDays": null,
        "maxDays": null,
        "toDate": formattedToDate,
        "assignedUserID": null,
        "sessionId": currentSessionId
      };

      var response =
          await ledgerOutstandingSummaryReportListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData);
          int totalRows = 0;

          double pendingAmount = 0;

          // Calculate totals
          for (var invoice in Invoices!) {
            totalRows++;

            if (invoice['Pending Amount'] != null) {
              pendingAmount += invoice['Pending Amount'];
            }
          }
          totalData = [
            {'Total Rows': totalRows.toString()},
            {'Total Pending Amount': pendingAmount.toString()}
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
  void dispose() {
    _tabController.dispose(); // Clean up the controller
    _pageController.dispose(); // Clean up the PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AbsAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ledger Outstanding Summary',
                    style: listTitle,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Add TabBar here
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: Text('Ledger Search')),
                  Tab(icon: Text('Ledger Outstanding')),
                ],
                labelColor: abs_blue,
                unselectedLabelColor: Colors.grey,
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 480, // Specify a height for the TabBarView
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [LedgerSearch(), LedgerOutstanding()],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 100,
        margin: EdgeInsets.only(bottom: 40),
        child: FloatingActionButton(
          onPressed: () {
            navigateToSecondTab();
          },
          child: Text('Outstanding'),
        ),
      ),
      bottomSheet: commanBottomSheet(totalData),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  void navigateToSecondTab() {
    if (selectedLedgerIds.isNotEmpty) {
      _tabController.animateTo(1);
      getList();
    } // Index of the second tab
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please Select Ledger'),
        ),
      );
    }
  }

  onLedgerSearch(String searchTxt) async {
    DateTime parsedToDate = DateFormat('dd/MM/yyyy HH:mm:ss').parse(toDate);

    String formattedToDate =
        DateFormat('dd/MM/yyyy 23:59:59').format(parsedToDate);
    setState(() {
      isLoading = true;
      selectedLedgerIds = [];
    });
    try {
      var requestBody = {
        "isSync": false,
        "name": searchTxt,
        "assignedUserID": null,
        "groups": _selectedGroupId != null ? [_selectedGroupId] : [],
        // "groups": groupID != null ? [groupID] : [],
        "includeChildGroups": true,
        "toDate": formattedToDate,
        "lockFreeze": false,
        "sessionId": currentSessionId
      };

      var response = await searchLedgerService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          ledgers = List<Map<String, dynamic>>.from(decodedData['list']);
          int totalRows = 0;

          double pendingAmount = 0;

          // Calculate totals
          for (var invoice in ledgers!) {
            totalRows++;
          }
          totalData = [
            {'Total Rows': totalRows.toString()},
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

  Widget LedgerSearch() {
    final borderColor = Colors.grey.shade300;
    return Container(
        //margin: EdgeInsets.only(bottom: 0),
        child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: groupradios.map((group) {
            return InkWell(
              onTap: () => _handleRadioValueChange(group['id']),
              child: Row(
                children: [
                  Radio<int>(
                    value: group['id'],
                    groupValue: _selectedGroupId,
                    onChanged: _handleRadioValueChange,
                  ),
                  Text(group['name']),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _ledgerController,
                decoration: InputDecoration(
                  labelText: 'Search Ledger',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: abs_blue),
                  ),
                ),
                onChanged: (value) {
                  onLedgerSearch(value);
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  fixedSize: Size(95, 20),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    side: BorderSide(
                        width: 2, color: abs_blue), // Border color and width
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
                            child: LedgerOutSummaryFilterPopup(
                              onSubmit: updateDates,
                              groupid: groupID,
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
            )
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: toggleSelectAll,
              child: Text(
                'Select All',
                style: TextStyle(color: abs_blue),
              ),
            ),
            Checkbox(
              value: selectAll,
              onChanged: (value) {
                toggleSelectAll();
              },
            ),
            const SizedBox(width: 25),
          ],
        ),

        const SizedBox(height: 2),
        isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: ledgers?.length ?? 0,
                  itemBuilder: (context, index) {
                    if (ledgers == null || ledgers!.isEmpty) {
                      return Center(
                        child: Text('No invoices found'),
                      );
                    }
                    var ledger = ledgers![index];
                    bool isSelected =
                        selectedLedgerIds.contains(ledger['ledger_id']);
                    return GestureDetector(
                        onTap: () => {
                              setState(() {
                                if (isSelected) {
                                  selectedLedgerIds.remove(ledger['ledger_id']);
                                } else {
                                  selectedLedgerIds.add(ledger['ledger_id']);
                                }
                              })
                            },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          color: Colors.white,
                          child: ListTile(
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedLedgerIds.add(ledger['ledger_id']);
                                  } else {
                                    selectedLedgerIds
                                        .remove(ledger['ledger_id']);
                                  }
                                });
                                print('selectedLedgerIds$selectedLedgerIds');
                              },
                            ),
                            title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('Ledger', style: cardmaincontent),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(':', style: cardmaincontent),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth:
                                              260), // Adjust the maxWidth as needed
                                      child: Text(
                                        '${ledger['name'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  ),
                                ]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                if (ledger['group'] != null &&
                                    ledger['group'] != "")
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Group',
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
                                            '${ledger['group'] ?? ''}',
                                            overflow: TextOverflow.ellipsis,
                                            style: cardcontent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 5),
                                if (ledger['address'] != null &&
                                    ledger['address'] != "")
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Address',
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
                                            '${ledger['address'] ?? ''}',
                                            overflow: TextOverflow.ellipsis,
                                            style: inter11400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 5),
                                if (ledger['contactInfo'] != null &&
                                    ledger['contactInfo'] != "")
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Contact Info',
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
                                            '${ledger['contactInfo'] ?? ''}',
                                            overflow: TextOverflow.ellipsis,
                                            style: cardcontent,
                                          ),
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
              ),
        // const SizedBox(height: 185),
      ],
    ));
  }

  Widget LedgerOutstanding() {
    //getList();
    return Column(
      children: [
        const SizedBox(height: 15),
        isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Expanded(
                child: ListView.builder(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (invoice['Party'] != null &&
                                    invoice['Party'] != "")
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('Party', style: cardmaincontent),
                                  ),
                                Expanded(
                                  flex: 1,
                                  child: Text(':', style: cardmaincontent),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            260), // Adjust the maxWidth as needed
                                    child: Text(
                                      '${invoice['Party'] ?? ''}',
                                      overflow: TextOverflow.ellipsis,
                                      style: cardcontent,
                                    ),
                                  ),
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
                                    if (invoice['City'] != null &&
                                        invoice['City'] != "")
                                      Expanded(
                                        flex: 2,
                                        child: Text('City',
                                            style: cardmaincontent),
                                      ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(':', style: cardmaincontent),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth:
                                                260), // Adjust the maxWidth as needed
                                        child: Text(
                                          '${invoice['City'] ?? ''}',
                                          overflow: TextOverflow.ellipsis,
                                          style: cardcontent,
                                        ),
                                      ),
                                    ),
                                  ]),
                              const SizedBox(height: 5),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (invoice['Contact No.'] != null &&
                                        invoice['Contact No.'] != "")
                                      Expanded(
                                        flex: 2,
                                        child: Text('Contact No',
                                            style: cardmaincontent),
                                      ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(':', style: cardmaincontent),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth:
                                                260), // Adjust the maxWidth as needed
                                        child: Text(
                                          '${invoice['Contact No.'] ?? ''}',
                                          overflow: TextOverflow.ellipsis,
                                          style: cardcontent,
                                        ),
                                      ),
                                    ),
                                  ]),
                              const SizedBox(height: 5),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (invoice['Pending Amount'] != null &&
                                        invoice['Pending Amount'] != "")
                                      Expanded(
                                        flex: 2,
                                        child: Text('Pending Amount',
                                            style: cardmaincontent),
                                      ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(':', style: cardmaincontent),
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        constraints: BoxConstraints(
                                            maxWidth:
                                                260), // Adjust the maxWidth as needed
                                        child: Text(
                                            '${formatAmount(invoice['Pending Amount'].toString())}  ${invoice['DrCr'] ?? ''}',
                                            style: crAmnt),
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ));
                },
              )),
      ],
    );
  }
}
