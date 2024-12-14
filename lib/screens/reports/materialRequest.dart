import 'dart:convert';
import 'dart:io';

import 'package:abs/global/invoiceTypes.dart';
import 'package:abs/global/utils.dart';
import 'package:abs/layouts/absappbar.dart';
import 'package:abs/layouts/absbottomNavigation.dart';
import 'package:abs/screens/comman-widgets/filterPopup.dart';
import 'package:abs/screens/comman-widgets/invoicemenulist.dart';
import 'package:abs/screens/comman-widgets/itemsearch.dart';
import 'package:abs/screens/comman-widgets/ledgersearch.dart';
import 'package:abs/screens/stock/materialRequestSlip.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/itemService.dart';
import 'package:abs/services/reportsService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../global/styles.dart';
import '../../../layouts/absdrawer.dart';
import '../comman-widgets/invoice-dialog.dart';

class MaterialRequestScreen extends StatefulWidget {
  final int rid;
  final InvoiceType invoiceType;
  const MaterialRequestScreen(
      {super.key, required this.rid, required this.invoiceType});

  @override
  State<MaterialRequestScreen> createState() => _MaterialRequestScreen();
}

class _MaterialRequestScreen extends State<MaterialRequestScreen>
    with TickerProviderStateMixin {
  final borderColor = Colors.grey.shade300;
  final TextStyle cardHeader = const TextStyle(
    fontSize: 15,
    color: abs_blue,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );

  final TextStyle carddate = const TextStyle(
    fontSize: 14,
    color: abs_grey,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle cardmaincontent = TextStyle(
    fontSize: 13,
    color: Color.fromRGBO(0, 0, 0, 1),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );

  final TextStyle greyPoppins = GoogleFonts.poppins(
    fontSize: 12,
    color: Color.fromRGBO(113, 113, 113, 1),
    fontWeight: FontWeight.w400,
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

  final BoxDecoration attachmentContainer = BoxDecoration(
    color: Color.fromRGBO(248, 248, 248, 1),
    borderRadius: BorderRadius.circular(8),
  );
  bool isItemLoading = false;
  bool isBtnLoading = false;
  bool isLoading = true;
  bool isDeleteDocLoading = true;

  String userData = '';
  late String currentSessionId;
  Map<String, dynamic> companyData = {};
  List spIds = [0, 1, 2, 3, 4, 5, 6, 7];
  List<Map<String, dynamic>>? Invoices;
  String searchText = '';
  int? itemsid;
  String selectedLedger = '';
  late int selectedLedgerId;
  bool isUpdateState = false;
  Map<String, dynamic>? selectedItem;
  final ledgerDescription = TextEditingController();
  final referenceNumber = TextEditingController();
  List<Map<String, dynamic>> plantList = [];
  Map<String, dynamic>? _selectedPlant;
  List<Map<String, dynamic>> machineNameList = [];
  Map<String, dynamic>? _selectedMachine;
  int? _selectedPlantID;
  TextEditingController _selectedDate = TextEditingController();
  double itemTotal = 0;
  List<Map<String, dynamic>> selectedItems = [];
  List<XFile> selectedFiles = [];
  List<dynamic> uploadedFiles = [];
  String billNo = '';
  String ladgerLabel = '';
  int? invoice_typeID;
  bool showLedger = true;

  late String fromDate;
  late String toDate;
  DateTime firstDayOfMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime lastDayOfMonth = DateTime.now();
  late List<bool> _isExpanded;
  bool _isExpandedAttachments = false;
  bool _isExpandedDesc = false;
  String todaysDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final GlobalKey<SearchItemState> _searchItemKey =
      GlobalKey<SearchItemState>();
  final GlobalKey<SearchLedgerState> _searchLedgerKey =
      GlobalKey<SearchLedgerState>();
  List<Map<String, String>> totalData = [
    {'Total Qty': '00'},
    {'Total Amount': '00'},
    {'Grand Total': '00'},
  ];
  Map<String, dynamic> ledgerFilter = {
    "groups": [],
    "includeChildGroups": true,
    "lockFreeze": false
  };

  int? businessTypeId;
  dynamic setupinfoData;
  int? stockPlace;
  List<dynamic> stockPlaceList = [];

  void updateDates(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
  }

  void _showLedger() {
    setState(() {
      showLedger = true;
    });

    // Use Future.delayed to wait until the widget is rendered
    Future.delayed(Duration(milliseconds: 100), () {
      _searchLedgerKey.currentState?.focusLedgerField();
    });
  }

  late ScaffoldMessengerState scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    // Avoid calling ScaffoldMessenger.of(context) here
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    invoice_typeID = widget.invoiceType.id;
    print('InvoiceType:${widget.invoiceType}');
    fromDate = DateFormat('dd/MM/yyyy 00:00:00').format(firstDayOfMonth);
    toDate = DateFormat('dd/MM/yyyy 23:59:59').format(lastDayOfMonth);
    getCompanyData();
    loadUserData();

    resolveValuesForType(widget.invoiceType, ActionType.newAction);
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
        companyData = userData['company'];
        if (currentSessionId != null) {
          setState(() {
            this.currentSessionId = currentSessionId;
          });
          print('Loaded currentSessionId: $currentSessionId');
          if (widget.rid != 0) {
            setState(() {
              isUpdateState = true;
              showLedger = false;
            });
            await getPlantnames();
            await getsetupInfo();
            await getRequestInfo();
          } else {
            await getsetupInfo();
            await getPlantnames();

            setState(() {
              isUpdateState = false;
            });
          }
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

  Future<Map<String, dynamic>> getItemInfo(itemID) async {
    setState(() {
      isItemLoading = true;
    });
    var ItemInfo;
    try {
      var requestBody = {"id": itemID, "sessionId": currentSessionId};

      var response = await getItemInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          ItemInfo = Map<String, dynamic>.from(decodedData);
        });
      }
      setState(() {
        isItemLoading = false;
      });
      return ItemInfo;
    } catch (e) {
      print('Error: $e');
      setState(() {
        isItemLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
    return ItemInfo;
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
      setState(() {
        selectedItem = items;
      });
      print('selectedItem$selectedItem');
    }
  }

  void clearSearchItem() {
    _searchItemKey.currentState?.onClearItem();
  }

  Future<void> getRequestInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "id": widget.rid,
        "invType": widget.invoiceType.id
      };

      var response = await getInvoiceService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var object = decodedData;
          print('object: $object');
          billNo = object['bill_No'];
          object['note'] != null
              ? ledgerDescription.text = object['note']
              : ledgerDescription.text = '';
          object['refNo'] != null
              ? referenceNumber.text = object['refNo']
              : referenceNumber.text = '';
          object['refNo'] != null
              ? _selectedDate.text = DateFormat('yyyy-MM-dd').format(
                  DateFormat('yyyy-MM-ddT00:00:00').parse(object['refDate']))
              : _selectedDate.text = '';
          if (object['plantname_ID'] != null) {
            setSelectedPlantById(object['plantname_ID']);
          }

          if (object['machinename_ID'] != null) {
            setSelectedMachineById(object['machinename_ID']);
          }
          selectedItems = (object['invoiceItemDetail'] as List)
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          stockPlace = object['spCode'] ?? stockPlaceList.first['spId'];
          print('stockPlacetesting$stockPlace');
          _isExpanded = List<bool>.filled(selectedItems.length, false);
          getLedgers(object['ledger_ID']);
          if (object['documents'] != null) {
            uploadedFiles = (object['documents'] as List<dynamic>);
          } else {
            uploadedFiles = [];
          }
        });

        for (int index = 0; index < selectedItems.length; index++) {
          var item = selectedItems[index];
          print('item:$item');
          var fullItem = await getItemInfo(item['item_ID']);
          selectedItems[index]['name'] = fullItem['name'];
          selectedItems[index]['item_code'] = fullItem['item_CodeTxt'];
        }
      }
      calculateTotal();
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  Future<void> getPlantnames() async {
    try {
      var requestBody = {
        "type": 27,
        "table": 22,
        "sessionId": currentSessionId
      };
      //await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          plantList = List<Map<String, dynamic>>.from(decodedData);
          print('plantList: $plantList');
        });
      }
    } catch (e) {
      print('Error: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  void setSelectedPlantById(int id) {
    final selectedPlant =
        plantList.firstWhere((plant) => plant['id'] == id, orElse: () => {});
    if (selectedPlant.isNotEmpty) {
      setState(() {
        _selectedPlant = selectedPlant;
      });
    } else {
      print('Plant with id $id not found');
    }
  }

  Future<void> getMachinenames() async {
    try {
      var requestBody = {
        "type": 28,
        "table": 22,
        "sessionId": currentSessionId
      };
      //await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var machineList = List<Map<String, dynamic>>.from(decodedData);
          print('machineList: $machineNameList');
          machineNameList = machineList
              .where((m) => m['field1'] == _selectedPlant?['id'].toString())
              .toList();
          if (!machineNameList.contains(_selectedMachine)) {
            _selectedMachine = null;
          }
        });
      }
    } catch (e) {
      print('Error: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
    }
  }

  void setSelectedMachineById(int id) {
    final selectedMachine = machineNameList
        .firstWhere((item) => item['id'] == id, orElse: () => {});
    if (selectedMachine.isNotEmpty) {
      setState(() {
        _selectedMachine = selectedMachine;
      });
    } else {
      print('Plant with id $id not found');
    }
  }

  Future<void> getsetupInfo() async {
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "fromInvoice": true,
        "invtype": widget.invoiceType.id
      };
      //await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      var response = await getSetupInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          setupinfoData = decodedData;
          List<dynamic> stockPlaceList_ = setupinfoData['billingPlaces'];
          stockPlaceList = stockPlaceList_;
          if (businessTypeId == 27) {
            stockPlaceList =
                stockPlaceList_.where(((test) => test['spId'] != 0)).toList();
          }
          stockPlace = stockPlaceList.first['spId'];
          if (setupinfoData.containsKey('groupsAssociated')) {
            ledgerFilter['groups'].addAll(setupinfoData['groupsAssociated']
                .map((group) => group['invGroup']));
          }
          print('setupinfoData: $setupinfoData');
          isLoading = false; // Set loading state to false
        });
      }
    } catch (e) {
      print('Error: $e');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("Something Went Wrong"),
        ),
      );
      setState(() {
        isLoading = false; // Set loading state to false on error
      });
    }
  }

  getLedgers(ledgerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      var ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      Map<String, dynamic>? filteredLedger = ledgers.firstWhere(
        (ledger) => ledger['id'] == ledgerId,
      );
      print('filteredLedger$filteredLedger');
      setState(() {
        selectedLedger = filteredLedger['name'];
        selectedLedgerId = filteredLedger['id'];
      });
    }
    // Trigger a rebuild to update the UI
  }

  addItem() async {
    print('itemadded');
    if (selectedItem != null) {
      var fullItem = await getItemInfo(selectedItem!['iid']);
      print('fullItem$fullItem');
      var result = invoiceGridCalculations(
        gstType: 4,
        qty: 1,
        rate: fullItem['std_Sell_Rate'],
        disc1: 0.0,
        disc2: 0.0,
        disc3: 0.0,
        ratedisc: fullItem['discount'],
        vat: fullItem['vatPer'],
        conversions: 1,
        basecurrency: 0,
        precision: 2,
      );
      var newItem = {
        "sessionId": currentSessionId,
        "item_ID": selectedItem!['iid'],
        "invType": invoice_typeID,
        "invoiceNo": 1,
        "std_Qty": 1,
        "inventoryMoved": setupinfoData['stockEffect'] * 1,
        "itemDescription": "",
        "name": selectedItem!['nm'],
        "item_code": selectedItem!['ict'],
        "std_Rate": fullItem['std_Sell_Rate'],
        "amount": fullItem['std_Sell_Rate'],
        "rateDiscount": fullItem['discount'],
        "sp_Code": stockPlace,
        "conv_Unit": null,
        "conv_Rate": 25.42,
        "discount1": 0,
        "discount2": 0,
        "conv_Qty": 1,
        "conversion": 1,
        "landing": 720,
        "cost_Rate": 0,
        "profit": 0,
        "scheduleDate": "2024-09-16T00:00:00.000Z",
        "deliveryDate": "2024-09-16T00:00:00.000Z",
        "cgstPer": result['cgstPer'],
        "cgstAmt": result['cgstAmt'],
        "sgstPer": result['sgstPer'],
        "sgstAmt": result['sgstAmt'],
        "result": result['igstPer'],
        "igstPer": result['igstPer'],
        "igstAmt": result['igstAmt'],
        "hsn": fullItem['hsnNo'],
        "vatPer": fullItem['vatPer'].toDouble(),
        "isExtraChargeItem": false,
        "sno": 1,
        "invoiceItemSubDetail": [
          {
            "qty": 01,
            "new0_Against1": false,
            "refName": "",
            "effect": setupinfoData['stockEffect'],
            "conversion": 1,
            "invType": invoice_typeID
          },
        ],
        "invoiceItemBatchNo": [],
        "invoiceItemPIDNo": [],
        "invoiceQCListObservation": []
      };

      bool itemExists = false;

      setState(() {
        for (var item in selectedItems) {
          if (item['item_ID'] == newItem['item_ID'] &&
              item['amount'] == newItem['amount'] &&
              item['itemDescription'] == newItem['itemDescription']) {
            item['std_Qty'] += newItem['std_Qty'];
            item['amount'] = item['std_Qty'] * item['std_Rate'];
            itemExists = true;
            break;
          }
        }

        if (!itemExists) {
          selectedItems.add(newItem);
          _isExpanded = List<bool>.filled(selectedItems.length, false);
          _searchItemKey.currentState?.onClearItem();
        }
      });
      calculateTotal();
      print('selectedItems$selectedItems');
      selectedItem = null;
    }
  }

  calculateTotal() {
    print('caulculatetotal');
    double totalQty = 0.0;
    double totalAmount = 0.0;

    for (var item in selectedItems) {
      // Convert std_Qty and amount to double if they are not already
      double qty = (item['std_Qty'] is int)
          ? (item['std_Qty'] as int).toDouble()
          : item['std_Qty'] as double;
      double amount = (item['amount'] is int)
          ? (item['amount'] as int).toDouble()
          : item['amount'] as double;

      totalQty += qty;
      totalAmount += amount;
    }

    setState(() {
      totalData[0]['Total Qty'] = totalQty.toStringAsFixed(2);
      totalData[1]['Total Amount'] = totalAmount.toStringAsFixed(2);
      totalData[2]['Grand Total'] = totalAmount.toStringAsFixed(2);
    });
  }

  submit() {
    if (selectedLedger.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select ledger'),
        ),
      );
    } else {
      if (selectedItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please add atlest 1 item'),
          ),
        );
      } else {
        setState(() {
          isBtnLoading = true;
        });
        if (isUpdateState) {
          updateInvoice();
        } else {
          submitInvoice();
        }
      }
    }
  }

  submitInvoice() async {
    calculateItemsTotal();
    print('submit');
    lastBillNo();
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "inv_Type": invoice_typeID,
        "spCode": stockPlace.toString(),
        "ledger_ID": selectedLedgerId,
        "recBy": "Credit",
        "billStatus": 0,
        "bill_No": '',
        "itemID_Qty": selectedItems.length,
        "date": DateFormat('yyyy/MM/dd 23:59:59').format(DateTime.now()),
        "gstType": 2,
        "invoiceNo": 1,
        "useInCompany": true,
        "invoiceItemDetail": selectedItems,
        "isGenerated": false,
        "isApproved": false,
        "isAuthorised": false,
        "isAuthorized": false,
        "isHold": false,
        "shiptoLedgerID": selectedLedgerId,
        "buyerLedgerID": selectedLedgerId,
        "orderItemId": null,
        "orderQty": null,
        "orderInvcode": null,
        "workType": 0,
        "poNumber": "",
        "poRecDate": null,
        "yourRefDate": null,
        "yourRefNo": "",
        "transactionType": 1,
        "poDate": null,
        "departmentId": null,
        "departmentUserId": 113,
        "partyDeliveryAddress": null,
        "companyDeliveryAddress": null,
        "lrNo": null,
        "vehicleNo": null,
        "deliveryBy": null,
        "paymentTerms": null,
        "kindAttention": null,
        "projectName": null,
        "remark": null,
        "otherRefNo": null,
        "otherRefDate": null,
        "note": ledgerDescription.text,
        "transportBy": null,
        "ledgerOrder": null,
        "ledgerorderNo": null,
        "ledgerContactPerson": null,
        "ledgerContactPersonMobile": "-  -",
        "refInv_Type": null,
        "againstRefNo": null,
        "againstRefDate": null,
        "bomRefName": "",
        "paymentInfo": null,
        "voucherId": null,
        "supplyTo": 27,
        "invoiceTncMap": [],
        "compBaseCurr": 2,
        "invoiceBaseCurr": 2,
        "currRate": 1,
        "currTotal": "30.00",
        "surveyNo": null,
        "surveyDate": null,
        "weight": null,
        "estWeight": null,
        "wastageweight": null,
        "eWayBillNo": null,
        "pidNoRefName": null,
        "iec_No": "",
        "bank_AD_Code": "",
        "loadingPort": "",
        "dischargePort": "",
        "final_Destination": "",
        "country_Org_Goods": "",
        "delivery_Terms": "",
        "airway_BillNo": "",
        "shipping_BillNo": "",
        "modeOfPacking": "",
        "no_Of_Packages": "",
        "grossWeight": "",
        "netWeight": "",
        "dimension_Inches": "",
        "tot_GrossWeight": "",
        "tot_NetWeight": "",
        "entry_BillNo": "",
        "entry_BillDate": "",
        "bankCharges": "",
        "customClearanceCharges": "",
        "customDuty": "",
        "freightCharges": "",
        "idProjectFeeder": null,
        "iddtrname": null,
        "membershipinclusion": false,
        "ewayBillJson": null,
        "eWB": null,
        "eWBSignedQRCode": null,
        "eWayBillDate": null,
        "dispatchFrom_EWB": null,
        "shipTo_EWB": null,
        "distanceInKM": null,
        "transportLedgerId": null,
        "transportMode": null,
        "transportDocNo": null,
        "transportDocDate": null,
        "vehicleNumber": null,
        "vehicleTypeId": null,
        "refNo": referenceNumber.text,
        "refDate": _selectedDate.text != '' ? _selectedDate.text : null,
        "orderNo": null,
        "orderDate": null,
        "projectSiteId": null,
        "projectSiteAddress": null,
        "item_SubTotal": itemTotal,
        "extra_SubTotal": 0,
        "grandTotal": itemTotal,
        "plantname_ID": _selectedPlant?['id'],
        "machinename_ID": _selectedMachine?['id']
      };

      var response = await createInvoiceService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          var reqInfo = Map<String, dynamic>.from(decodedData);
          if (selectedFiles.isNotEmpty) {
            uploadDoc(reqInfo['invCode']);
          } else {
            setState(() {
              isBtnLoading = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MaterialRequestSlipScreen(
                        invoiceType: widget.invoiceType,
                      )),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        isBtnLoading = false;
      });
      if (mounted) {
        print('Error: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('$e'),
          ),
        );
      }
    }
  }

  updateInvoice() async {
    calculateItemsTotal();
    print('update');
    lastBillNo();
    try {
      var requestBody = {
        "id": widget.rid,
        "sessionId": currentSessionId,
        "inv_Type": invoice_typeID,
        "spCode": 0,
        "ledger_ID": selectedLedgerId,
        "recBy": "Credit",
        "billStatus": 0,
        "bill_No": '',
        "itemID_Qty": selectedItems.length,
        "date": DateFormat('yyyy/MM/dd 23:59:59').format(DateTime.now()),
        "gstType": 2,
        "invoiceNo": 1,
        "useInCompany": true,
        "invoiceItemDetail": selectedItems,
        "isGenerated": false,
        "isApproved": false,
        "isAuthorised": false,
        "isAuthorized": false,
        "isHold": false,
        "shiptoLedgerID": selectedLedgerId,
        "buyerLedgerID": selectedLedgerId,
        "orderItemId": 0,
        "orderQty": 0,
        "orderInvcode": 0,
        "workType": 0,
        "poNumber": "",
        "poRecDate": null,
        "yourRefDate": null,
        "yourRefNo": "",
        "transactionType": 1,
        "poDate": null,
        "departmentId": null,
        "departmentUserId": 113,
        "partyDeliveryAddress": null,
        "companyDeliveryAddress": null,
        "lrNo": null,
        "vehicleNo": null,
        "deliveryBy": null,
        "paymentTerms": null,
        "kindAttention": null,
        "projectName": null,
        "remark": null,
        "otherRefNo": null,
        "otherRefDate": null,
        "note": ledgerDescription.text,
        "transportBy": null,
        "ledgerOrder": null,
        "ledgerorderNo": null,
        "ledgerContactPerson": null,
        "ledgerContactPersonMobile": "-  -",
        "refInv_Type": null,
        "againstRefNo": null,
        "againstRefDate": null,
        "bomRefName": "",
        "paymentInfo": null,
        "voucherId": null,
        "supplyTo": 96,
        "invoiceTncMap": [],
        "refNo": referenceNumber.text,
        "refDate": _selectedDate.text != '' ? _selectedDate.text : null,
        "orderNo": null,
        "orderDate": null,
        "projectSiteId": null,
        "projectSiteAddress": null,
        "item_SubTotal": itemTotal,
        "extra_SubTotal": 0,
        "grandTotal": itemTotal,
        "plantname_ID": _selectedPlant?['id'],
        "machinename_ID": _selectedMachine?['id']
      };

      var response = await updateInvoiceService(requestBody);
      var decodedData = jsonDecode(response.body);
      setState(() {
        isBtnLoading = false;
      });
      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          var reqInfo = Map<String, dynamic>.from(decodedData);
          if (selectedFiles.isNotEmpty) {
            uploadDoc(reqInfo['invCode']);
          } else {
            setState(() {
              isBtnLoading = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MaterialRequestSlipScreen(
                        invoiceType: widget.invoiceType,
                      )),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        isBtnLoading = false;
      });
      if (mounted) {
        print('Error: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('$e'),
          ),
        );
      }
    }
  }

  uploadDoc(reqId) async {
    try {
      var file = selectedFiles.first;
      print('file$file');
      var postUri =
          Uri.parse("https://erpapi.abssoftware.in/api/Invoice/UploadDocument");
      var request = http.MultipartRequest("POST", postUri);
      request.fields['id'] = reqId.toString();
      request.fields['sessionId'] = currentSessionId;
      request.files.add(await http.MultipartFile.fromPath(
          'attachedFile', file.path,
          filename: file.name));

      request.send().then((response) {
        setState(() {
          isBtnLoading = false;
        });
        if (response.statusCode == 200) print("Uploaded!");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MaterialRequestSlipScreen(
                    invoiceType: widget.invoiceType,
                  )),
        );
      });
    } catch (e) {
      setState(() {
        isBtnLoading = false;
      });
      if (mounted) {
        print('Error: $e');
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('$e'),
          ),
        );
      }
    }
  }

  calculateItemsTotal() {
    for (var item in selectedItems) {
      if (item['amount'] != null) {
        itemTotal += item['amount'];
      }
    }
  }

  void ledgerChange(String items) {
    // print('items' + items);
    // setState(() {
    //   searchText = items;
    // });
    //getList();
  }

  ledgerSelect(Map<String, dynamic> ledger) {
    if (ledger.isNotEmpty) {
      setState(() {
        selectedLedger = ledger['name'];
        selectedLedgerId = ledger['id'];
      });
    }
  }

  void handleFilePicked(XFile? file) {
    if (file != null) {
      setState(() {
        selectedFiles.add(file);
      });
    }
  }

  deleteDocument(id, tableId) async {
    setState(() {
      isDeleteDocLoading = true;
    });
    try {
      var requestBody = {
        "id": id,
        "tableId": tableId,
        "sessionId": currentSessionId
      };

      var response = await deleteInvoiceDocService(requestBody);
      var decodedData = jsonDecode(response.body);
      setState(() {
        isDeleteDocLoading = false;
      });
      getRequestInfo();
      if (response.statusCode == 200) {}
    } catch (e) {
      print('Error: $e');
      setState(() {
        isDeleteDocLoading = false;
      });
      getRequestInfo();
    }
  }

  // Function to increment item quantity
  void itemIncrement(int index) {
    setState(() {
      selectedItems[index]['std_Qty'] =
          (selectedItems[index]['std_Qty'] ?? 0) + 1;
      selectedItems[index]['amount'] = selectedItems[index]['std_Qty'] *
          (selectedItems[index]['std_Rate'] ?? 0);

      selectedItems[index]['invoiceItemSubDetail'][0]['qty'] =
          selectedItems[index]['std_Qty'];
      selectedItems[index]['inventoryMoved'] =
          setupinfoData['stockEffect'] * selectedItems[index]['std_Qty'] ?? 0;
      selectedItems[index]['conv_Qty'] =
          (selectedItems[index]['conv_Qty'] ?? 0) + 1;
    });
    calculateTotal();
  }

  // Function to decrement item quantity
  void itemDecrement(int index) {
    setState(() {
      if ((selectedItems[index]['std_Qty'] ?? 0) > 1) {
        selectedItems[index]['std_Qty'] -= 1;
        selectedItems[index]['conv_Qty'] -= 1;
        selectedItems[index]['amount'] = selectedItems[index]['std_Qty'] *
            (selectedItems[index]['std_Rate'] ?? 0);
        selectedItems[index]['inventoryMoved'] =
            setupinfoData['stockEffect'] * selectedItems[index]['std_Qty'] ?? 0;

        selectedItems[index]['invoiceItemSubDetail'][0]['qty'] =
            selectedItems[index]['std_Qty'];
      } else {
        selectedItems.removeAt(index);
      }
    });
    calculateTotal();
  }

  void removeAttachement(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  lastBillNo() async {
    try {
      var requestBody = {
        "invtype": invoice_typeID,
        "sessionId": currentSessionId
      };

      var response = await createBillNo(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {}
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
  }

  clearForm() {
    setState(() {
      isUpdateState = false;
      selectedFiles = [];
      selectedLedger = '';
      ledgerDescription.text = '';
      selectedItems = [];
      _searchLedgerKey.currentState?.onClearLedger();
      _searchItemKey.currentState?.onClearItem();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MaterialRequestScreen(
                  rid: 0,
                  invoiceType: widget.invoiceType,
                )),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String getInvoiceDescription(InvoiceType invoiceType) {
    return InvoiceVoucherTypesObjByte[invoiceType] ?? 'Unknown Invoice Type';
  }

  void resolveValuesForType(InvoiceType type, ActionType action) {
    ladgerLabel = type.getLedgerLabel();
    print('ladgerLabel$ladgerLabel');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AbsAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(50, 40),
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          shadowColor: const Color.fromRGBO(0, 0, 0, 0),
                          backgroundColor: Color.fromARGB(255, 209, 208, 208),
                        ),
                        onPressed: () {
                          clearForm();
                        },
                        child: Image.asset('assets/icons/eraser-fill.png',
                            height: 20),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(50, 40),
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          shadowColor: const Color.fromRGBO(0, 0, 0, 0),
                          backgroundColor: Color.fromARGB(255, 209, 208, 208),
                        ),
                        onPressed: () {
                          final RenderBox button =
                              context.findRenderObject() as RenderBox;
                          final RenderBox overlay = Overlay.of(context)
                              .context
                              .findRenderObject() as RenderBox;
                          final Offset position = button
                              .localToGlobal(Offset.zero, ancestor: overlay);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return InvoiceDialog(
                                id: widget.rid.toString(),
                                invoiceType: widget.invoiceType,
                                sessionId: '',
                                invType: widget.invoiceType.id,
                              );
                            },
                          );
                        },
                        child: Icon(
                          Icons.print,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (showLedger)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Expanded(
                            child: SearchLedger(
                              key: _searchLedgerKey,
                              onTextChanged: ledgerChange,
                              onledgerSelects: ledgerSelect,
                              ledgerFilter: ledgerFilter,
                              ledgerLabel: ladgerLabel,
                            ),
                          ),
                  ],
                ),
              const SizedBox(height: 15),
              if (stockPlaceList.length > 1) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: stockPlace,
                        decoration: InputDecoration(
                          labelText: businessTypeId == 27
                              ? 'Company Name'
                              : 'Stock Place',
                          border: borderStyle,
                          enabledBorder: borderStyle,
                          focusedBorder: borderStyle,
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            child: Text(businessTypeId == 27
                                ? 'Select Company Name'
                                : 'Select Stock Place'),
                            value: null, // Representing a null value
                          ),
                          ...stockPlaceList.map((sp) => DropdownMenuItem<int?>(
                                child: Text(sp['name']),
                                value: sp['spId'],
                              )),
                        ],
                        onChanged: (int? newValue) {
                          print('newValue$newValue');
                          setState(() {
                            stockPlace =
                                newValue; // Allow null value assignment
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15)
              ],
              ExpansionPanelList(
                elevation: 1,
                expandedHeaderPadding: EdgeInsets.all(0),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isExpandedDesc = !_isExpandedDesc;
                  });
                },
                children: [
                  ExpansionPanel(
                    backgroundColor: Colors.white,
                    isExpanded: _isExpandedDesc,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text('Advance Option', style: cardmaincontent),
                      );
                    },
                    body: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(children: [
                          TextFormField(
                            controller: referenceNumber,
                            decoration: InputDecoration(
                              labelText: 'Reference Number',
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
                            maxLines: 1,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Reference Date',
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
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => {_selectDate(context)},
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              controller: _selectedDate),
                          const SizedBox(height: 10),
                          companyData['businessType'] == 27
                              ? DropdownButtonFormField<Map<String, dynamic>>(
                                  value: _selectedPlant,
                                  decoration: InputDecoration(
                                    labelText: 'Plant Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .grey), // Replace borderColor with actual color
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .grey), // Replace borderColor with actual color
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .blue), // Replace abs_blue with actual color
                                    ),
                                  ),
                                  items: plantList
                                      .map((Map<String, dynamic> plant) {
                                    return DropdownMenuItem<
                                        Map<String, dynamic>>(
                                      value: plant,
                                      child: Text(plant['name']),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    setState(() {
                                      print('Selected value: $value');
                                      _selectedPlant = value;
                                    });
                                    await getMachinenames();
                                  },
                                )
                              : Container(),
                          const SizedBox(height: 10),
                          companyData['businessType'] == 27
                              ? DropdownButtonFormField<Map<String, dynamic>>(
                                  value: _selectedMachine,
                                  decoration: InputDecoration(
                                    labelText: 'Machine Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .grey), // Replace borderColor with actual color
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .grey), // Replace borderColor with actual color
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .blue), // Replace abs_blue with actual color
                                    ),
                                  ),
                                  items: machineNameList
                                      .map((Map<String, dynamic> plant) {
                                    return DropdownMenuItem<
                                        Map<String, dynamic>>(
                                      value: plant,
                                      child: Text(plant['name']),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      print('Selected value: $value');
                                      _selectedMachine = value;
                                    });
                                  },
                                )
                              : Container(),
                        ])),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.only(bottom: 80),
                color: Colors.white,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SearchItem(
                          key: _searchItemKey,
                          onTextChanged: itemsChange,
                          onitemselects: itemsSelect,
                        ),
                      ),
                      const SizedBox(width: 5),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(20, 58),
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          shadowColor: const Color.fromRGBO(0, 0, 0, 0),
                          backgroundColor: abs_blue,
                        ),
                        onPressed: () {
                          addItem();
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$billNo',
                            style: cardHeader,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/calendar.png',
                                height: 16,
                                width: 16,
                              ),
                              const SizedBox(width: 10),
                              Text(todaysDate, style: carddate),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Ledger :', style: cardmaincontent),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        '$selectedLedger',
                                        style: cardcontent,
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            child: Image.asset(
                              'assets/icons/edit.png',
                              height: 24,
                              width: 24,
                            ),
                            onTap: () {
                              _showLedger();
                            },
                            onTapUp: (details) {},
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Divider(),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text(
                                'Item Name',
                                style: cardmaincontent,
                              )),
                          Expanded(
                              flex: 3,
                              child: Text(
                                'Qty',
                                style: cardmaincontent,
                              )),
                          Expanded(
                              flex: 2,
                              child: Text(
                                'Amount',
                                style: cardmaincontent,
                              ))
                        ],
                      ),
                      Divider(),
                      const SizedBox(height: 5),
                      isItemLoading
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: abs_blue,
                                    strokeWidth: 3,
                                  ),
                                )
                              ],
                            )
                          : Column(
                              children: selectedItems.map<Widget>((item) {
                                int index = selectedItems.indexOf(item);
                                return Card(
                                  shape: BeveledRectangleBorder(),
                                  color: Colors.white,
                                  margin: EdgeInsets.only(bottom: 10.0),
                                  child: Column(
                                    children: [
                                      customHeader(
                                          index, item, _isExpanded[index]),
                                      _isExpanded[index]
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          initialValue:
                                                              item['std_Qty']
                                                                  .toString(),
                                                          onChanged:
                                                              (String value) {
                                                            setState(() {
                                                              item[
                                                                  'std_Qty'] = double
                                                                      .tryParse(
                                                                          value) ??
                                                                  int.tryParse(
                                                                      value) ??
                                                                  0;
                                                              if (item[
                                                                      'std_Qty'] ==
                                                                  0) {
                                                                item['std_Qty'] =
                                                                    1;
                                                              }
                                                              item[
                                                                  'amount'] = item[
                                                                      'std_Qty'] *
                                                                  (item['std_Rate'] ??
                                                                      0);
                                                              item['invoiceItemSubDetail']
                                                                          [0]
                                                                      ['qty'] =
                                                                  item[
                                                                      'std_Qty'];
                                                              calculateTotal();
                                                            });
                                                          },
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText: 'Qty',
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          borderColor),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          borderColor),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color:
                                                                          abs_blue),
                                                            ),
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          initialValue:
                                                              item['std_Rate']
                                                                  .toString(),
                                                          onChanged:
                                                              (String value) {
                                                            setState(() {
                                                              item[
                                                                  'std_Rate'] = double
                                                                      .tryParse(
                                                                          value) ??
                                                                  int.tryParse(
                                                                      value) ??
                                                                  0;

                                                              item[
                                                                  'amount'] = item[
                                                                      'std_Qty'] *
                                                                  (item['std_Rate'] ??
                                                                      0);
                                                              calculateTotal();
                                                            });
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText: 'Rate',
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          borderColor),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          borderColor),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color:
                                                                          abs_blue),
                                                            ),
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                        child: TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          initialValue: item[
                                                                  'rateDiscount']
                                                              .toString(),
                                                          onChanged:
                                                              (String value) {
                                                            setState(() {
                                                              item[
                                                                  'rateDiscount'] = double
                                                                      .tryParse(
                                                                          value) ??
                                                                  int.tryParse(
                                                                          value)
                                                                      ?.toDouble() ??
                                                                  0;

                                                              double discount =
                                                                  item['rateDiscount'] ??
                                                                      0;
                                                              item['amount'] = item[
                                                                      'std_Qty'] *
                                                                  item[
                                                                      'std_Rate'] *
                                                                  (1 -
                                                                      discount /
                                                                          100);
                                                              calculateTotal();
                                                            });
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Discount',
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          borderColor),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  BorderSide(
                                                                      color:
                                                                          borderColor),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color:
                                                                          abs_blue),
                                                            ),
                                                          ),
                                                          maxLines: 1,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  TextFormField(
                                                    initialValue:
                                                        item['itemDescription'],
                                                    onChanged: (String value) {
                                                      setState(() {
                                                        item['itemDescription'] =
                                                            value;
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      labelText: 'Description',
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        borderSide: BorderSide(
                                                            color: Colors.grey),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        borderSide: BorderSide(
                                                            color: Colors.blue),
                                                      ),
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 5),
                      const SizedBox(height: 5),
                      ExpansionPanelList(
                        elevation: 1,
                        expandedHeaderPadding: EdgeInsets.all(0),
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            _isExpandedAttachments = !_isExpandedAttachments;
                          });
                        },
                        children: [
                          ExpansionPanel(
                              backgroundColor: Colors.white,
                              isExpanded: _isExpandedAttachments,
                              headerBuilder:
                                  (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  title: Text('Attachments',
                                      style: cardmaincontent),
                                );
                              },
                              body: Column(children: [
                                const SizedBox(height: 5),
                                FilePickerWidget(
                                    onFilePicked: handleFilePicked),
                                const SizedBox(height: 5),
                                ListView.builder(
                                  padding: EdgeInsets.all(2),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  // gridDelegate:
                                  //     const SliverGridDelegateWithFixedCrossAxisCount(
                                  //   childAspectRatio: 3,
                                  //   crossAxisCount: 2, // 2 columns
                                  //   crossAxisSpacing:
                                  //       8.0, // Space between columns
                                  //   mainAxisSpacing:
                                  //       8.0, // Space between rows
                                  // ),
                                  itemCount: uploadedFiles.length,
                                  itemBuilder: (context, index) {
                                    final file = uploadedFiles[index];
                                    return Container(
                                      height: 60,
                                      padding: EdgeInsets.only(left: 10),
                                      decoration: attachmentContainer,
                                      width: 159,
                                      child: Row(children: [
                                        Expanded(
                                          child: Text(
                                            file['fileName'],
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                            iconSize: 20,
                                            onPressed: () {
                                              deleteDocument(
                                                  file['id'], file['tableId']);
                                            },
                                            icon: Icon(Icons.delete))
                                      ]),
                                    );
                                  },
                                ),
                              ]))
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 42,
                            width: 140,
                            decoration: BoxDecoration(
                              color: abs_blue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () {
                                submit();
                              },
                              child: isBtnLoading
                                  ? Container(
                                      height: 20,
                                      width: 20,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isUpdateState ? "Update" : "Create",
                                      style: GoogleFonts.poppins(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 42,
                            width: 140,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 209, 208, 208),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () {
                                clearForm();
                              },
                              child: Text(
                                "Clear",
                                style: GoogleFonts.poppins(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: materialBottomSheet(context, totalData),
    );
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
                    Text(
                        key == 'Total Qty'
                            ? '$formattedValue'
                            : '₹$formattedValue',
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

  Widget customHeader(int index, Map<String, dynamic> item, bool isExpanded) {
    String itemname = item['name'] ?? '';

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            '${itemname} :',
            style: cardmaincontent,
          ),
        ),
        Container(
          width: 90, // Fixed width for the entire quantity control container
          clipBehavior: Clip.none,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.transparent,
            border: Border.all(color: abs_blue),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () => itemDecrement(index),
                child: Icon(
                  Icons.remove,
                  color: abs_blue,
                  size: 14,
                ),
              ),
              Container(
                width: 30, // Fixed width for the quantity display
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 3, // Reduce horizontal padding
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white,
                  border: Border.all(color: abs_blue),
                ),
                child: FittedBox(
                  // Ensure the text fits within the container
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${item['std_Qty']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => itemIncrement(index),
                child: Icon(
                  Icons.add,
                  color: abs_blue,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
            // Ensure the text fits within the container
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${formatItemAmount(item['amount'])}',
              textAlign: TextAlign.right,
              style: cardmaincontent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded[index] = !_isExpanded[index];
              });
            },
            child: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
          ),
        ),
      ],
    );
  }
}

Object formatItemAmount(dynamic amount) {
  try {
    final double amountDouble = amount is int ? amount.toDouble() : amount;
    final NumberFormat numberFormat = NumberFormat("#,##,##0.00", "en_IN");
    return numberFormat.format(amountDouble);
  } catch (e) {
    return amount; // Return the original value if parsing fails
  }
}

class FilePickerWidget extends StatefulWidget {
  final Function(XFile?) onFilePicked;

  FilePickerWidget({required this.onFilePicked, selectedImage});

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    File? _selectedImage;
    String _base64Image;
    return Center(
      child: GestureDetector(
        onTap: () async {
          final pickedFile =
              await ImagePicker().pickImage(source: ImageSource.gallery);

          if (pickedFile != null) {
            _selectedImage = File(pickedFile.path);
            widget.onFilePicked(pickedFile);
            final bytes = await File(pickedFile.path).readAsBytes();
            final base64Image = base64Encode(bytes);

            _base64Image = base64Image;
            setState(() {
              selectedImage = File(pickedFile.path);
            });
          }
        },
        child: Container(
          height: 109,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 57,
                width: 57,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(225, 225, 225, 1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: selectedImage == null
                    ? Image.asset(
                        'assets/icons/addphoto.png',
                        width: 24,
                        height: 24,
                      )
                    : Image.file(
                        selectedImage!,
                        width: 57,
                        height: 57,
                        fit: BoxFit.cover,
                      ),
              ),
              selectedImage == null
                  ? Text('Upload File', style: TextStyle(color: Colors.blue))
                  : TextButton(
                      onPressed: () {
                        setState(() {
                          selectedImage = null;
                        });
                        widget.onFilePicked(null);
                      },
                      child: Text('Remove File',
                          style: TextStyle(color: Colors.blue))),
            ],
          ),
        ),
      ),
    );
  }
}

class ReadMoreText extends StatefulWidget {
  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText>
    with SingleTickerProviderStateMixin {
  final TextStyle greyPoppins = GoogleFonts.poppins(
    fontSize: 12,
    color: Color.fromRGBO(113, 113, 113, 1),
    fontWeight: FontWeight.w400,
  );
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final text =
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet accumsan tortor. '
        'Nullam condimentum, odio at cursus venenatis, arcu nulla luctus nisl, non lobortis justo mauris vel augue. '
        'Sed eu magna euismod, luctus erat in, aliquet nunc. Sed suscipit tortor metus, ac laoreet ligula iaculis sed. '
        'In volutpat, risus vitae elementum egestas, nisi orci vehicula sapien, sed luctus turpis dui ac libero.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: _isExpanded ? text : text.substring(0, 100) + '...',
            style: greyPoppins,
            children: [
              if (!_isExpanded)
                TextSpan(
                  text: ' Read More',
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                ),
            ],
          ),
        ),
        if (_isExpanded)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = false;
              });
            },
            child: Text(
              'Read Less',
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
