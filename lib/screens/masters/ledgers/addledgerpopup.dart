import 'dart:convert';

import 'package:abs/global/appCommon.dart';
import 'package:abs/global/styles.dart';
import 'package:abs/screens/masters/customdropdown.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/ledgerService.dart';
import 'package:abs/services/sessionIdFetch.dart';
import 'package:abs/services/syncService.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class addLedgerPopup extends StatefulWidget {
  final Function(String, String) onSubmit; // Define callback function
  final int? group_Id;

  addLedgerPopup({required this.onSubmit, this.group_Id});

  @override
  _addLedgerPopupState createState() => _addLedgerPopupState();
}

class _addLedgerPopupState extends State<addLedgerPopup> {
  final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide:
          BorderSide(width: 1, color: Color.fromRGBO(235, 235, 235, 1)));
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  late ScrollController _scrollController;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController mobilecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController addresscontroller = TextEditingController();
  TextEditingController gstcontroller = TextEditingController();
  TextEditingController areacontroller = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  String? currentSessionId;
  List<dynamic> salesPersons = [];
  List<dynamic> stateList = enStateCode;
  List<dynamic> countryList = [];
  List<String> cityList = [];
  List<String> areaList = [];
  List<dynamic> _cityList = [];
  List<Map<String, dynamic>>? groups = [];
  int stateId = 4;
  int? groupId;
  int countryId = 3;
  int? salesPerson;

  @override
  void initState() {
    super.initState();
    loadSessionId();
    getGroups();
    _scrollController = ScrollController();

    _textEditingController.addListener(() {
      setState(() {
        _showClearIcon = _textEditingController.text.isNotEmpty;
      });
    });
  }

  void loadSessionId() async {
    String? sessionId = await UserDataUtil.getSessionId();

    if (sessionId != null) {
      setState(() {
        currentSessionId = sessionId;

        getSalesPersons();
        getCities('City');
        getArea('Area');
        getState();
        getCountry();
      });
      print('Loaded currentSessionId: $sessionId');
    } else {
      print('Session ID not found');
    }
  }

  getSalesPersons() async {
    try {
      var requestBody = {"table": 18, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          salesPersons = decodedData;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  getCountry() async {
    try {
      var requestBody = {"table": 22, "type": 3, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          countryList = decodedData;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
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

  getCities(columnTxt) async {
    try {
      var requestBody = {"table": 22, "type": 1, "sessionId": currentSessionId};

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          for (var item in decodedData) {
            cityList.add(item['name']);
          }
          _cityList = decodedData;
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  getArea(columnTxt) async {
    try {
      var requestBody = {
        "table": 3,
        "column": columnTxt,
        "sessionId": currentSessionId
      };

      var response = await distinctService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          for (var item in decodedData) {
            columnTxt == "Area" ? areaList.add(item['name']) : null;
          }
        });
      } else {}
    } catch (e) {
      print('Error: $e');
    }
  }

  submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      create();
    }
  }

  create() async {
    var grpId;
    if (widget.group_Id == null) {
      grpId = groupId;
    } else {
      grpId = widget.group_Id;
    }
    try {
      var requestBody = {
        "id": null,
        "name": namecontroller.text,
        "group_ID": grpId ?? 17,
        "address": addresscontroller.text,
        "area": areacontroller.text,
        "city": citycontroller.text,
        "state": stateId,
        "mobile": mobilecontroller.text,
        "email": emailcontroller.text,
        "gstNo": gstcontroller.text,
        "pinCode": null,
        "phone_1": null,
        "phone_2": null,
        "fax": null,
        "website": null,
        "tinV": null,
        "gstCategory": null,
        "gstType": 1,
        "opening_Bal": 0,
        "isCr": false,
        "credit_Limit": 0,
        "lock_Freeze": false,
        "creditDays": 0,
        "accountName": null,
        "bankName": null,
        "bankBranch": null,
        "brankAccountNo": null,
        "ifsc": null,
        "accounNo": null,
        "contactPerson": [],
        "contact_Person": null,
        "partyType": 1,
        "opening_Date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "panNo": null,
        "assignedUserID": salesPerson,
        "openingDetails": [],
        "bankDetails": [],
        "sessionId": currentSessionId
      };

      var response = await createledgerService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (mounted) {
        // Check if the widget is still mounted
        if (response.statusCode == 200) {
          ledgerSync();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        //isBtnLoading = false;
      });
      if (mounted) {
        print('Error: $e');
      }
    }
  }

  getGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? groupList = prefs.getStringList('group-list');
    if (groupList != null) {
      groups = groupList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
      groups = groups!
          .where((group) => group['id'] != 16 && group['id'] != 17)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
  }

  onClearLedger() {
    _textEditingController.clear();
    setState(() {
      _showClearIcon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final dropDownKey = GlobalKey<DropdownSearchState>();
    return Dialog(
        alignment: Alignment.center,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Spacer(flex: 1),
                          Text(
                            'Add Ledger',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Spacer(flex: 1),
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.black,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Name', border: borderStyle),
                        controller: namecontroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      if (widget.group_Id == null)
                        Autocomplete<Map<String, dynamic>>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<
                                  Map<String, dynamic>>.empty();
                            }
                            return groups!.where((ledger) {
                              return ledger['name'].toLowerCase().contains(
                                  textEditingValue.text.toLowerCase());
                            });
                          },
                          displayStringForOption:
                              (Map<String, dynamic> option) => option['name'],
                          fieldViewBuilder: (BuildContext context,
                              TextEditingController textEditingController,
                              FocusNode focusNode,
                              VoidCallback onFieldSubmitted) {
                            _textEditingController = textEditingController;
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onChanged: (text) {
                                print('Text field value changed: $text');
                                setState(() {
                                  _showClearIcon = text.isNotEmpty;
                                });
                              },
                              onFieldSubmitted: (text) {
                                focusNode.unfocus();
                              },
                              decoration: InputDecoration(
                                constraints: BoxConstraints(
                                    minHeight: 53,
                                    maxHeight: 53,
                                    maxWidth: 348),
                                suffixIcon: _showClearIcon
                                    ? IconButton(
                                        onPressed: () {
                                          onClearLedger();
                                        },
                                        icon: Icon(
                                            color: Colors.black, Icons.close),
                                      )
                                    : null,
                                contentPadding: EdgeInsets.all(13),
                                hintText: 'Group',
                                hintStyle: hintStyle,
                                border: borderStyle,
                                enabledBorder: borderStyle,
                                focusedBorder: borderStyle,
                              ),
                              maxLines: 1,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'This field is required.';
                                }
                                // const Text('This field is required');
                                return null;
                              },
                            );
                          },
                          optionsViewBuilder: (BuildContext context,
                              AutocompleteOnSelected<Map<String, dynamic>>
                                  onSelected,
                              Iterable<Map<String, dynamic>> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                child: Container(
                                    height: 500,
                                    width: 340,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: RawScrollbar(
                                      thumbColor: abs_blue,
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      thickness: 8,
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: EdgeInsets.all(10.0),
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final Map<String, dynamic> option =
                                              options.elementAt(index);
                                          return ListTile(
                                            title: Text(option['name']),
                                            onTap: () {
                                              onSelected(option);
                                              groupId = option['id'];
                                              print(
                                                  'Selected: ${option['name']}');
                                            },
                                          );
                                        },
                                      ),
                                    )),
                              ),
                            );
                          },
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                            hintText: 'Address', border: borderStyle),
                        controller: addresscontroller,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomDropdownSearch(
                        items: areaList,
                        labelText: 'Area',
                        thumbColor: Colors.blue,
                        onChanged: (String? value) {
                          if (value != null) {
                            areacontroller.text = value;
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomDropdownSearch(
                        items: cityList,
                        labelText: 'City',
                        thumbColor: Colors.blue,
                        onChanged: (String? value) {
                          if (value != null) {
                            citycontroller.text = value;
                            final city = _cityList
                                .firstWhere((city) => city['name'] == value);
                            print('city$city');

                            setState(() {
                              stateId = int.tryParse(city['field1'])!;

                              print('stateId$stateId');
                            });
                            var stateObj;
                            stateObj = stateList
                                .where((s) => s['id'] == stateId)
                                .first;
                            setState(() {
                              countryId = int.tryParse(stateObj['field1'])!;
                            });
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Pin Code', border: borderStyle),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<int>(
                        value: stateId,
                        menuMaxHeight: 420,
                        decoration: InputDecoration(
                            labelText: 'State',
                            border: borderStyle,
                            enabledBorder: borderStyle,
                            focusedBorder: borderStyle),
                        items: stateList
                            .map((sp) => DropdownMenuItem<int>(
                                  child: Text(sp['name']!),
                                  value: sp['id'],
                                ))
                            .toList(),
                        onChanged: (value) {
                          var stateObj;
                          stateObj =
                              stateList.where((s) => s['id'] == value).first;

                          print('value$value');
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<int>(
                        value: countryId,
                        menuMaxHeight: 420,
                        decoration: InputDecoration(
                            labelText: 'Country',
                            border: borderStyle,
                            enabledBorder: borderStyle,
                            focusedBorder: borderStyle),
                        items: countryList
                            .map((sp) => DropdownMenuItem<int>(
                                  child: Text(sp['name']!),
                                  value: sp['id'],
                                ))
                            .toList(),
                        onChanged: (value) {
                          var stateObj;
                          stateObj =
                              countryList.where((s) => s['id'] == value).first;

                          print('value$value');
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Mobile ', border: borderStyle),
                        controller: mobilecontroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Email', border: borderStyle),
                        controller: emailcontroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required.';
                          }
                          // const Text('This field is required');
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            hintText: 'GSTIN', border: borderStyle),
                        controller: gstcontroller,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: abs_blue,
                              boxShadow: [],
                              borderRadius: BorderRadius.circular(6.0)),
                          child: TextButton(
                              onPressed: () {
                                submit();
                              },
                              child: Text(
                                'Create',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      )
                    ],
                  ),
                ))));
  }
}

class City {
  final String name;

  City({required this.name});

  @override
  String toString() {
    return name;
  }

  bool isEqual(City other) {
    return this.name == other.name;
  }
}
