import 'dart:convert';
import 'package:abs/global/styles.dart';
import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absdrawer.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/screens/dashboard/dashboard.dart';
import 'package:abs/screens/masters/ledgers/addledgerpopup.dart';
import 'package:abs/screens/masters/ledgers/ledgerfilterpopup.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/ledgerService.dart';
import 'package:abs/services/sessionCheckService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LedgersListScreen extends StatefulWidget {
  const LedgersListScreen({super.key});
  @override
  State<LedgersListScreen> createState() => _LedgersListScreenState();
}

class _LedgersListScreenState extends State<LedgersListScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isLoading = true;

  String userData = '';
  late String currentSessionId;
  String BillNo = '';
  String? ledgername;
  int? ledgerid;
  double totalGrandAmnt = 0;
  List<dynamic> stateList = [];
  late String fromDate;
  late String toDate;
  String city = '';
  String area = '';
  int? grpId = 17;
  int _currentTabIndex = 0;
  late TabController _tabController;

  List<Map<String, dynamic>>? Invoices;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    isValidSession();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index; // Update current tab index
        });
        // Perform actions based on the current tab index
        if (_currentTabIndex == 0) {
          setState(() {
            grpId = 17;
          });
          getList();
        } else if (_currentTabIndex == 1) {
          setState(() {
            grpId = 16;
          });
          getList();
        } else {
          setState(() {
            grpId = null;
          });
          getList();
        }
      }
    });
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    loadUserData();
  }

  void updateDates(String _city, int? grpid, String _area) {
    setState(() {
      city = _city;
      area = _area;
    });
    getList();
  }

  getList() async {
    setState(() {
      isLoading = true;
    });
    final Map<String, dynamic> jsonBody = {
      "isSync": false,
      "name": ledgername,
      "area": area,
      "city": city,
      "groups": grpId != null ? [grpId] : null,
      "includeChildGroups": true,
      "sessionId": currentSessionId,
    };
    print('jsonBody: ${jsonBody}');
    try {
      var response = await ledgerListService(jsonBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData['list']);
          //totalRows = 00;
          totalGrandAmnt = 00;
          for (var invoice in Invoices!) {
            //totalRows++;
          }
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

  getState() async {
    try {
      var requestBody = {"table": 22, "type": 2, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          stateList = decodedData;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  getStateNameById2(int stateID) {
    String stateName = '';

    var state =
        stateList.firstWhere((o) => o['id'] == stateID, orElse: () => {});
    if (state.isNotEmpty) {
      stateName = state['name'];
    }
    return stateName;
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
          getState();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        break;
      case 1:
        Navigator.pushNamed(context, '/sales');
        break;
      case 2:
        Navigator.pushNamed(context, '/purchase');
        break;
      case 3:
        Navigator.pushNamed(context, '/stock');
        break;
      case 4:
        Navigator.pushNamed(context, '/account');
        break;
      default:
        break;
    }
  }

  ledgerSelect(Map<String, dynamic> ledger) {
    print('ledger' + ledger.toString());
    ledgerid = ledger['id'];
    if (ledgerid != null) {
      ledgername = ledger['name'];
      getList();
    } else {
      ledgername = null;
      getList();
    }
  }

  void billNoChange(String bill) {
    print('billNoChange' + bill);
    setState(() {
      BillNo = bill;
      fromDate = '';
      toDate = '';
    });
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbsAppBar(),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            child: SearchLedger(
              onTextChanged: billNoChange,
              onledgerSelects: ledgerSelect,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Text('Customers')),
              Tab(icon: Text('Suppliers')),
              Tab(icon: Text('Others')),
            ],
            labelColor: abs_blue,
            unselectedLabelColor: Colors.grey,
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ledger Listings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  height: 40,
                  width: 120,
                  decoration: BoxDecoration(
                      color: abs_blue,
                      boxShadow: [],
                      borderRadius: BorderRadius.circular(6.0)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        //fixedSize: Size(95, 20),
                        backgroundColor: Colors.transparent,
                        elevation: 0),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (grpId != null)
                          GestureDetector(
                            child: grpId == 17
                                ? Text(
                                    'Add Customer',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    'Add Supplier',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return addLedgerPopup(
                                      onSubmit: (String, Object) {},
                                      group_Id: grpId);
                                },
                              );
                            },
                          ),
                        if (grpId == null)
                          GestureDetector(
                            child: Text(
                              'Add Ledger',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return addLedgerPopup(
                                      onSubmit: (String, Object) {},
                                      group_Id: grpId);
                                },
                              );
                            },
                          )
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                      color: abs_blue,
                      boxShadow: [],
                      borderRadius: BorderRadius.circular(6.0)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        //fixedSize: Size(95, 20),
                        backgroundColor: Colors.transparent,
                        elevation: 0),
                    onPressed: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: Colors.transparent, // No backdrop
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
                                child: LedgerFilterPopup(
                                  onSubmit: updateDates,
                                  initialValues: {
                                    'city': city,
                                    'group': grpId,
                                    'area': area
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Image.asset(
                          'assets/icons/filter.png',
                          width: 20,
                          height: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
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
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 6,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${invoice['name'] ?? ''}',
                                    style: inter600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 6,
                            // ),
                            // Text(
                            //   'Group: ${invoice['group'] ?? ''}',
                            //   style: inter_13_500,
                            // ),
                            SizedBox(
                              height: 2,
                            ),
                            if (invoice['contactInfo'] != null &&
                                invoice['contactInfo'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Contact Info',
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
                                        '${invoice['contactInfo'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            if (invoice['address'] != null &&
                                invoice['address'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('Address', style: cardmaincontent),
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
                                        '${invoice['address'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: inter11400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            if (invoice['state'] != null &&
                                invoice['state'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('State', style: cardmaincontent),
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
                                        '${getStateNameById2(int.tryParse(invoice['state']) ?? 0)}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            if (invoice['gstNo'] != null &&
                                invoice['gstNo'] != "")
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('GST', style: cardmaincontent),
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
                                        '${invoice['gstNo'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Divider()
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          totalRowsBottomBar(
            rows: Invoices?.length.toString() ?? '0',
          ),
        ],
      ),
    );
  }
}

class totalRowsBottomBar extends StatelessWidget {
  final TextStyle inter14_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  final TextStyle inter13_w600 = GoogleFonts.inter(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );
  final String rows;

  totalRowsBottomBar({required this.rows});

  @override
  Widget build(BuildContext context) {
    // Format the total amount with commas
    return Container(
      padding: EdgeInsets.all(16),
      height: 56,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: abs_blue),
      child: BottomSheet(
        backgroundColor: Colors.transparent,
        onClosing: () {},
        builder: (BuildContext context) {
          return Column(
            children: [
              Row(
                children: [
                  Text(
                    'Total Rows :',
                    style: inter13_w600,
                  ),
                  Text(
                    ' $rows',
                    style: inter13_w600,
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
