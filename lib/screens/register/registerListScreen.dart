import 'dart:convert';

import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/register/registerform.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/registerService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../layouts/absdrawer.dart';

import '../../global/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterListScreen extends StatefulWidget {
  const RegisterListScreen({super.key});

  @override
  State<RegisterListScreen> createState() => _RegisterListScreen();
}

class _RegisterListScreen extends State<RegisterListScreen> {
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

  List<Map<String, dynamic>>? Invoices;
  bool isLoading = true;

  String userData = '';
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();
  late String currentSessionId;
  late String fromDate;
  late String toDate;
  int _registerInOut = 0;
  int? businessTypeId;
  List<dynamic> stockPlaceList = [];
  List<Map<String, dynamic>> _registerInOutList = [
    {'id': 0, 'type': 'All'},
    {'id': 1, 'type': 'IN'},
    {'id': 2, 'type': 'OUT'},
  ];

  List<Map<String, dynamic>> _registerTypes = [
    {'id': 1, 'type': 'Transport Bills'},
    {'id': 2, 'type': 'Store / Machenical Electrical Material'},
    {'id': 3, 'type': 'Job Work'},
    {'id': 4, 'type': 'RM / Fuel / Finish / Flakes / Powder'},
    {'id': 5, 'type': 'Government Documents / Telephone'},
    {'id': 6, 'type': 'Courier'},
  ];

  String getRegisterDocType(int rdocType) {
    final registerType = _registerTypes.firstWhere(
      (type) => type['id'] == rdocType,
      orElse: () =>
          {'id': 0, 'type': 'Unknown'}, // Fallback in case id is not found
    );
    return registerType['type'];
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

  @override
  void initState() {
    super.initState();
    getCompanyData();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(lastDayOfMonth);
    loadUserData();
  }

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    getList();
  }

  void _handleRadioValueChange(int? value) {
    setState(() {
      _registerInOut = value!;
      // Navigate to the second tab
    });
    getList();
  }

  Future<void> getsetupInfo() async {
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "fromInvoice": true,
        "invtype": 1
      };
      //await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      var response = await getSetupInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          dynamic setupinfoData = decodedData;
          List<dynamic> stockPlaceList_ = setupinfoData['billingPlaces'];
          stockPlaceList =
              stockPlaceList_.where(((test) => test['spId'] != 0)).toList();

          print('setupinfoData: $setupinfoData');
          isLoading = false; // Set loading state to false
        });
      }
    } catch (e) {
      print('Error: $e');

      setState(() {
        isLoading = false; // Set loading state to false on error
      });
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
        "sessionId": currentSessionId,
        "rtype": _registerInOut == 0 ? null : _registerInOut,
        "rdateTo": formattedToDate,
        "rdateFrom": formattedFromDate,
        "party_Name": ""
      };

      var response = await getRegisterListService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          Invoices = List<Map<String, dynamic>>.from(decodedData['list']);

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
    }
  }

  getSpName(spcode) {
    return stockPlaceList.firstWhere((test) => test['spId'] == spcode);
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
                    'Register List',
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
                                  initialFromDate: fromDate,
                                  initialToDate: toDate,
                                  onSubmit: updateDates,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: _registerInOutList.map((group) {
                  return InkWell(
                    onTap: () => _handleRadioValueChange(group['id']),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: group['id'],
                          groupValue: _registerInOut,
                          onChanged: _handleRadioValueChange,
                        ),
                        Text(group['type']),
                      ],
                    ),
                  );
                }).toList(),
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(bottom: 50),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: Invoices?.length ?? 0,
                      itemBuilder: (context, index) {
                        if (Invoices == null || Invoices!.isEmpty) {
                          return Center(
                            child: Text('No invoices found'),
                          );
                        }
                        var invoice = Invoices![index];
                        DateTime date = DateTime.parse(invoice['rdate']);
                        String formattedDate =
                            DateFormat('dd/MM/yyyy').format(date);
                        String registerType =
                            invoice['rtype'] == 2 ? 'OUT' : 'IN';
                        String registerDocType =
                            getRegisterDocType(invoice['rdocType']);
                        String Itemname = '-';
                        if (invoice['item_Desc'] != '') {
                          Itemname = invoice['item_Desc'];
                        }
                        String billNo = '-';
                        if (invoice['bill_No'] != '') {
                          Itemname = invoice['bill_No'];
                        }
                        String chlNo = '-';
                        if (invoice['challan_No'] != '') {
                          Itemname = invoice['challan_No'];
                        }
                        return Card(
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
                                      Text('$formattedDate', style: carddate),
                                    ],
                                  )
                                ]),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child:
                                          Text('Type', style: cardmaincontent),
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
                                          ' $registerDocType',
                                          style: cardcontent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text('Register No',
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
                                            '${invoice['rno']} $formattedDate $registerType',
                                            style: cardcontent),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
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
                                          '${invoice['party_Name']}',
                                          style: cardcontent,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text('Item Name',
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
                                          '$Itemname',
                                          style: cardcontent,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
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
                                      flex: 6,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text('Ch No/Bill No',
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
                                          '$chlNo / $billNo',
                                          style: cardcontent,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      child: Image.asset(
                                        'assets/icons/edit.png',
                                        height: 20,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  RegisterFormScreen(
                                                    rid: invoice['id'],
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
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: abs_blue,
          onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterFormScreen(
                            rid: 0,
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
          )),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
