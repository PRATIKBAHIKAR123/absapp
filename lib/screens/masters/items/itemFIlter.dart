import 'dart:convert';
import 'dart:ffi';

import 'package:abs/global/appCommon.dart';
import 'package:abs/global/styles.dart';
import 'package:abs/services/groupService.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/itemService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemFilterPopup extends StatefulWidget {
  final Function(String, String, String, String, String, String, int?)
      onSubmit; // Define callback function

  final String? initialToDate;
  final String? initialFromDate;
  final Map<String, dynamic>? initialValues;
  ItemFilterPopup({
    required this.onSubmit,
    this.initialToDate,
    this.initialFromDate,
    this.initialValues,
  });

  @override
  _ItemFilterPopupState createState() => _ItemFilterPopupState();
}

class _ItemFilterPopupState extends State<ItemFilterPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  String _toDate = '';
  List<Map<String, dynamic>> itemCodeList = [];
  List<Map<String, dynamic>> itemNameList = [];
  List<Map<String, dynamic>> brandList = [];
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> subCategoryList = [];
  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> brandCodeList = [];
  List<Map<String, dynamic>> stockPlaceList = [];

  String itemCode = '';
  String itemName = '';
  String brand = '';
  String category = '';
  String subCategory = '';
  int? usedFor;
  String type = '';
  String brandCode = '';
  String stockPlace = '';
  bool allStockPlaces = false;

  late String currentSessionId;
  bool isLoading = false;

  @override
  void dispose() {
    fromDate.dispose();
    toDate.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    isLoading = true;
    itemCode = widget.initialValues!['itemName'] ?? '';
    itemCode = widget.initialValues!['itemCode'] ?? '';
    brand = widget.initialValues!['brand'] ?? '';
    category = widget.initialValues!['category'] ?? '';
    subCategory = widget.initialValues!['subCategory'] ?? '';
    usedFor = widget.initialValues!['usedFor'];
    type = widget.initialValues!['type'] ?? '';
    brandCode = widget.initialValues!['brandCode'] ?? '';
    if (widget.initialValues!['stockPlace'] != null) {
      stockPlace = widget.initialValues!['stockPlace'].toString();
    }
    print('stockPlace$stockPlace');
    if (widget.initialFromDate != null) {
      fromDate.text = DateFormat('dd/MM/yyyy').format(
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialFromDate!));
    }
    if (widget.initialToDate != null) {
      toDate.text = DateFormat('dd/MM/yyyy').format(
          DateFormat('dd/MM/yyyy HH:mm:ss').parse(widget.initialToDate!));
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
          getItemCT();
          getName();
          getBrand();
          getCategory();
          getSubCategory();
          getType();
          getBrandCode();

          getStockPlaceList();
          print('Loaded currentSessionId: $currentSessionId');
          // Call getList() after loading user data
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

  Future<void> fetchData(String column,
      Function(List<Map<String, dynamic>>) setStateCallback) async {
    try {
      var requestBody = {
        "table": 0,
        "column": column,
        "sessionId": currentSessionId
      };

      var response = await getItemDistinctService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          setStateCallback(List<Map<String, dynamic>>.from(decodedData));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found for $column'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
  }

  void getItemCT() => fetchData("Item_CodeTxt", (data) => itemCodeList = data);
  void getBrand() => fetchData("Brand", (data) => brandList = data);
  void getCategory() => fetchData("Category", (data) => categoryList = data);
  void getSubCategory() => fetchData("Sizes", (data) => subCategoryList = data);
  void getType() => fetchData("Type", (data) => typeList = data);
  void getBrandCode() => fetchData("ItemGroup", (data) => brandCodeList = data);
  void getName() => fetchData("Name", (data) => itemNameList = data);

  Future<void> getStockPlaceList() async {
    try {
      var requestBody = {"table": 4, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          stockPlaceList = List<Map<String, dynamic>>.from(decodedData);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No details found'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No details found"),
        ),
      );
    }
  }

  Future<void> onTapFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2100),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    setState(() {
      fromDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  Future<void> onTapToDateFunction({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (pickedDate == null) return;

    setState(() {
      toDate.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    });
  }

  void submitDate() {
    print('itemCode: $itemCode');
    print('brand: $brand');
    print('category: $category');
    print('subCategory: $subCategory');
    print('type: $type');
    print('brandCode: $brandCode');
    String formattedFromDate =
        fromDate.text.isNotEmpty ? '${fromDate.text} 00:00:00' : '';
    String formattedToDate =
        toDate.text.isNotEmpty ? '${toDate.text} 23:59:59' : '';
    widget.onSubmit(
        itemCode, brand, category, subCategory, type, brandCode, usedFor);

    Navigator.of(context).pop();

    print('toDate: $formattedToDate');
  }

  onClearForm() {
    setState(() {
      itemCode = '';
      brand = '';
      category = '';
      subCategory = '';
      subCategory = '';
      type = '';
      brandCode = '';
      stockPlace = '';
      allStockPlaces = false;
      usedFor = null;
    });

    widget.onSubmit(
        itemCode, brand, category, subCategory, type, brandCode, usedFor);
    print('itemCode: $itemCode');
    print('brand: $brand');
    print('category: $category');
    print('subCategory: $subCategory');
    print('type: $type');
    print('brandCode: $brandCode');
    print('stockPlace: $stockPlace');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: usedFor,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Type',
                          ),
                          items: itemUsedForTypeForItemDropdown.map((item) {
                            return DropdownMenuItem<int>(
                              value: item['id'] as int?,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Text(
                                  item['text'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              usedFor = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Category',
                          ),
                          items: categoryList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['name'] as String,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Text(
                                  item['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              category = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: subCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Sizes',
                          ),
                          items: subCategoryList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['name'] as String,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Text(
                                  item['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              subCategory = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: type,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Type',
                          ),
                          items: typeList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['name'] as String,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Text(
                                  item['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              type = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: brand,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Brand',
                          ),
                          items: brandList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['name'] as String,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Text(
                                  item['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              brand = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: brandCode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Select Group',
                          ),
                          items: brandCodeList.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['name'] as String,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Text(
                                  item['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              brandCode = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 42,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                          ),
                          onPressed: () {
                            onClearForm();
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
                      Container(
                        height: 42,
                        width: 130,
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
                            submitDate();
                          },
                          child: Text(
                            "Apply Filter",
                            style: GoogleFonts.poppins(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
