import 'dart:convert';
import 'package:abs/global/styles.dart';
import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absdrawer.dart';
import 'package:abs/screens/comman-widgets/itemsearch.dart';
import 'package:abs/screens/masters/items/additempopup.dart';
import 'package:abs/screens/masters/items/itemFIlter.dart';
import 'package:abs/screens/masters/items/rateupdatepopup.dart';
import 'package:abs/services/itemService.dart';
import 'package:abs/services/sessionCheckService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemsListScreen extends StatefulWidget {
  const ItemsListScreen({super.key});
  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  int _selectedIndex = 0;
  bool isLoading = true;

  String userData = '';
  late String currentSessionId;
  String BillNo = '';
  String? itemname;
  int? itemid;
  double totalGrandAmnt = 0;
  late String fromDate;
  late String toDate;
  final GlobalKey<SearchItemState3> _searchItemKey =
      GlobalKey<SearchItemState3>();

  List<Map<String, dynamic>>? Invoices;

  String itemCode = '';
  String itemBrand = '';
  String itemCat = '';
  String itemSubCat = '';
  String itemType = '';
  String itemBrandCode = '';
  late String todaysDate;
  String salesPerson = '';
  int? spid;
  int? usedFor;

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

  @override
  void initState() {
    super.initState();
    isValidSession();
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(DateTime.now());
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(DateTime.now());
    loadUserData();
  }

  void onFilter(
      String _itemCode,
      String _itemBrand,
      String _itemCat,
      String _ItemSubCat,
      String _itemType,
      String _itemBrandCode,
      int? _usedFor) {
    setState(() {
      itemCode = _itemCode;
      itemBrand = _itemBrand;
      itemCat = _itemCat;
      itemSubCat = _ItemSubCat;
      itemType = _itemType;
      itemBrandCode = _itemBrandCode;
      usedFor = _usedFor;
    });
    getList();
  }

  getList() async {
    setState(() {
      isLoading = true;
    });
    final Map<String, dynamic> jsonBody = {
      "isSync": false,
      "brand": itemBrand == '' ? null : itemBrand,
      "category": itemCat == '' ? null : itemCat,
      "sizes": itemSubCat == '' ? null : itemSubCat,
      "type": itemType == '' ? null : itemType,
      "itemGroup": itemBrandCode == '' ? null : itemBrandCode,
      "name": null,
      "text": itemname,
      "usedFor": usedFor?.toString(),
      "sessionId": currentSessionId,
    };
    print('jsonBody: ${jsonBody}');
    try {
      var response = await itemListService(jsonBody);
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

  itemsSelect(Map<String, dynamic> items) async {
    print('items' + items.toString());
    itemid = items['iid'];

    if (itemid != null) {
      itemname = items['nm'];
    } else {
      itemname = null;
    }
    getList();
  }

  void itemrateUpdate(String from, String to) {
    getList();
  }

  void itemsChange(String items) {}

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
            padding: EdgeInsets.all(10),
            child: SearchItem3(
              key: _searchItemKey,
              onTextChanged: itemsChange,
              onitemSelects: itemsSelect,
            ),
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
                  'Items Listings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                  onSubmit: onFilter,
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
                                    'usedFor': usedFor
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
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Text(
                            'Add Item',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return addItemPopup(
                                  onSubmit: (String, Object) {},
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
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
                      DateTime date = DateTime.parse(invoice['modified_Date']);
                      String formattedDate = formatDateTime(date.toString());
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (invoice['item_CodeTxt'] != null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${invoice['item_CodeTxt']}',
                                      style: inter700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 6,
                            ),
                            if (invoice['name'] != null &&
                                invoice['name'] != "")
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('Name ', style: cardmaincontent),
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
                                        '${invoice['name'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            if (invoice['category'] != null &&
                                invoice['category'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Category ',
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
                                        '${invoice['category'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            if (invoice['sizes'] != null &&
                                invoice['sizes'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('Size ', style: cardmaincontent),
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
                                        '${invoice['sizes'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            if (invoice['type'] != null &&
                                invoice['type'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('Type ', style: cardmaincontent),
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
                                        '${invoice['type'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            if (invoice['brand'] != null &&
                                invoice['brand'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child:
                                        Text('Brand ', style: cardmaincontent),
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
                                        '${invoice['brand'] ?? ''}',
                                        overflow: TextOverflow.ellipsis,
                                        style: cardcontent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            if (invoice['itemGroup'] != null &&
                                invoice['itemGroup'] != "")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Item Group ',
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
                                        '${invoice['itemGroup'] ?? ''}',
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
                                  if (invoice['std_Unit'] != null &&
                                      invoice['std_Unit'] != "")
                                    Flexible(
                                        flex: 7,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 8,
                                              child: Text('UOM ',
                                                  style: cardmaincontent),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(':',
                                                  style: cardmaincontent),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Text(
                                                '${invoice['std_Unit'] ?? ''}',
                                                overflow: TextOverflow.ellipsis,
                                                style: cardcontent,
                                              ),
                                            )
                                          ],
                                        )),
                                  if (invoice['std_Sell_Rate'] != null &&
                                      invoice['std_Sell_Rate'] != "")
                                    Flexible(
                                        flex: 7,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text('Rate ',
                                                  style: cardmaincontent),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Text(':',
                                                  style: cardmaincontent),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Row(children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          260), // Adjust the maxWidth as needed
                                                  child: Text(
                                                    '₹${formatAmount((invoice['std_Sell_Rate'].toString())) ?? ''}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: cardcontent,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                GestureDetector(
                                                  child: Image.asset(
                                                    'assets/icons/edit.png',
                                                    height: 20,
                                                  ),
                                                  onTap: () {
                                                    showGeneralDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      //barrierColor: Colors.transparent, // No backdrop
                                                      barrierLabel:
                                                          'Popup', // Adding barrierLabel
                                                      transitionDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  200),
                                                      pageBuilder: (BuildContext
                                                              context,
                                                          Animation<double>
                                                              animation,
                                                          Animation<double>
                                                              secondaryAnimation) {
                                                        return Align(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Material(
                                                            type: MaterialType
                                                                .transparency,
                                                            child: Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              child:
                                                                  ItemRateUpdatePopup(
                                                                onSubmit:
                                                                    itemrateUpdate,
                                                                itemId: invoice[
                                                                    'item_ID'], // Example initial from date
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      transitionBuilder:
                                                          (context,
                                                              animation,
                                                              secondaryAnimation,
                                                              child) {
                                                        return SlideTransition(
                                                          position:
                                                              Tween<Offset>(
                                                            begin: Offset(0, 1),
                                                            end: Offset(0, 0),
                                                          ).animate(animation),
                                                          child: child,
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ]),
                                            ),
                                          ],
                                        )),
                                ]),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (invoice['vatPer'] != null &&
                                      invoice['vatPer'] != "")
                                    Flexible(
                                        flex: 7,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: invoice['hsnNo'] != null
                                                  ? 8
                                                  : 2,
                                              child: Text('TAX ',
                                                  style: cardmaincontent),
                                            ),
                                            Expanded(
                                              flex: invoice['hsnNo'] != null
                                                  ? 4
                                                  : 1,
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
                                                  '${formatAmount(invoice['vatPer'].toString()) ?? ''}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: cardcontent,
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  if (invoice['hsnNo'] != null &&
                                      invoice['hsnNo'] != "")
                                    Flexible(
                                        flex: 7,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text('HSN No ',
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
                                                  '${invoice['hsnNo'] ?? ''}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: cardcontent,
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                ]),
                            if (invoice['filename'] != null)
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Item Image ',
                                        style: cardmaincontent),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(':', style: cardmaincontent),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border(),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: const Color.fromARGB(
                                              255, 205, 240, 255)),
                                      child: Image.network(
                                        '${'http://erpapi.abssoftware.in/' + invoice['filename']}',
                                        height: 40,
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
      padding: EdgeInsets.all(10),
      height: 50,
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
