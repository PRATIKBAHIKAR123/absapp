import 'dart:io';

import 'package:abs/global/styles.dart';
import 'package:abs/screens/register/registerListScreen.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:abs/services/invoiceService.dart';
import 'package:abs/services/registerService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../layouts/absappbar.dart';
import '../../layouts/absdrawer.dart';

class RegisterFormScreen extends StatefulWidget {
  final int rid;
  const RegisterFormScreen({super.key, required this.rid});

  @override
  _RegisterFormScreenState createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isOut = true;
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime = TimeOfDay.now();
  int? _registerType;
  int? _selecteduser;
  String? _itemDescription;
  String? _nameController;
  String userData = '';
  late String currentSessionId;
  List<Map<String, dynamic>>? items = [];
  List<Map<String, dynamic>>? ledgers = [];
  List<Map<String, dynamic>>? users = [];
  bool isLoading = false;
  int? businessTypeId;
  int? stockPlace;
  List<dynamic> stockPlaceList = [];

  final _challanController = TextEditingController();
  final _billController = TextEditingController();
  final _docWeightController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactController = TextEditingController();
  final _noteController = TextEditingController();
  final _serialnumController = TextEditingController();

  final borderColor = Colors.grey.shade300;
  File? _selectedImage;
  String? _base64Image;
  bool _showClearIcon = false;
  bool _showClearIconItem = false;
  List<Map<String, dynamic>> _registerTypes = [
    {'id': 1, 'type': 'Transport Bills'},
    {'id': 2, 'type': 'Store / Machenical Electrical Material'},
    {'id': 3, 'type': 'Job Work'},
    {'id': 4, 'type': 'RM'},
    {'id': 5, 'type': 'Fuel'},
    {'id': 6, 'type': 'Finish'},
    {'id': 7, 'type': 'Flakes'},
    {'id': 8, 'type': 'Powder'},
    {'id': 9, 'type': 'Government Documents / Telephone'},
    {'id': 10, 'type': 'Courier'},
  ];

  List<Map<String, dynamic>> _registerInOut = [
    {'id': 0, 'type': 'All'},
    {'id': 1, 'type': 'Transport Bills'},
    {'id': 2, 'type': 'Store / Machenical Electrical Material'},
  ];

  Map<String, dynamic>? _selectedRegisterType;

  @override
  void initState() {
    super.initState();
    if (_registerTypes.isNotEmpty) {
      _selectedRegisterType = _registerTypes[0];
    }
    initializeData();
  }

  Future<void> initializeData() async {
    await loadUserData(); // Ensure this completes first
    getCompanyData();
    if (widget.rid != 0) {
      getRegisterInfo();
    } else {
      _nameController = '';
      _itemDescription = '';
    }
    getItems();
    getLedgers();
    getUsers();
  }

  getItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? itemList = prefs.getStringList('item-list');
    if (itemList != null) {
      items = itemList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
  }

  getLedgers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');
    if (ledgerList != null) {
      ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
  }

  Future<void> getRegisterInfo() async {
    print('checking getRegiterExecuring or not');
    setState(() {
      isLoading = true;
    });
    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "id": widget.rid,
      };

      var response = await getRegisterInfoService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var object = decodedData;
          print('obkect$object');
          _challanController.text = object['challan_No'] ?? '';
          _billController.text = object['bill_No'] ?? '';
          _serialnumController.text = object['serialNumber'] ?? '';
          _docWeightController.text = object['document_wt'] ?? '';
          _vehicleNoController.text = object['vehicleNo'] ?? '';
          _contactPersonController.text = object['contactPerson'] ?? '';
          _contactController.text = object['contactPersonNo'] ?? '';
          _selecteduser = object['notifyById'];
          _noteController.text = object['note'] ?? '';
          _isOut = object['rType'] == 1 ? false : true;
          _itemDescription = object['item_Desc'] ?? '';
          _nameController = object['party_Name'] ?? '';
          stockPlace = object['spcode'];
          _selectedRegisterType =
              _registerTypes.firstWhere((el) => el['id'] == object['rDocType']);
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

  Future<void> getCompanyData() async {
    Map<String, dynamic>? currentCompany =
        await CompanyDataUtil.getCompanyFromLocalStorage();
    setState(() {
      businessTypeId = currentCompany!['businessType'];
    });
    print('businessTypeId$businessTypeId');
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
          stockPlaceList = stockPlaceList_;
          if (businessTypeId == 27) {
            stockPlaceList =
                stockPlaceList_.where(((test) => test['spId'] != 0)).toList();
          }
          stockPlace = stockPlaceList.first['spId'];
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

  Future<void> getUsers() async {
    print('checking getRegiterExecuring or not');

    try {
      var requestBody = {
        "sessionId": currentSessionId,
        "table": 7,
      };

      var response = await dropdownService(requestBody);
      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          users = List<Map<String, dynamic>>.from(decodedData);
          print('users$users');
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time, {bool forDisplay = false}) {
    final now = DateTime.now();
    final formattedTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (forDisplay) {
      return DateFormat('hh:mm a').format(formattedTime); // 12-hour format
    } else {
      return DateFormat('HH:mm:ss').format(formattedTime); // 24-hour format
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> formData = {
        "sessionId": this.currentSessionId,
        "rno": widget.rid,
        "rdate": _selectedDate?.toIso8601String(),
        "rtime": _selectedTime != null ? _formatTime(_selectedTime!) : null,
        "rtype": _isOut ? 2 : 1,
        "rdocType": _selectedRegisterType!['id'],
        "serialNumber": _serialnumController.text,
        "party_Name": _nameController,
        "notifyById": _selecteduser,
        "item_Desc": _itemDescription,
        "challan_No": _challanController.text,
        "bill_No": _billController.text,
        "document_wt": _docWeightController.text,
        "vehicleNo": _vehicleNoController.text,
        "contactPerson": _contactPersonController.text,
        "contactPersonNo": _contactController.text,
        "note": _noteController.text,
        "fileImageUpload": _base64Image ?? "",
        "isAuthorized": true,
        "spcode": stockPlace
      };
      print(formData);

      try {
        var response = await createRegisterService(formData);

        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterListScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Something went wrong"),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("An error occurred"),
            ),
          );
        }
      }
    }
  }

  onClearLedger() {
    setState(() {
      _nameController = '';
      _showClearIcon = false;
    });
  }

  loadUserData() async {
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
          getsetupInfo();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AbsAppBar(),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _isOut
                              ? Text('Register Out', style: listTitle)
                              : Text('Register In', style: listTitle),
                          Row(
                            children: [
                              Text(_isOut ? 'OUT' : 'IN',
                                  style: TextStyle(color: abs_blue)),
                              Switch(
                                value: _isOut,
                                onChanged: (value) {
                                  setState(() {
                                    _isOut = value;
                                  });
                                },
                                activeColor: abs_blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _selectedRegisterType,
                        decoration: InputDecoration(
                          labelText: 'Type Of Register',
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
                        items: _registerTypes
                            .map((Map<String, dynamic> registerType) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: registerType,
                            child: Text(registerType['type']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            print('Selected value: $value');
                            _selectedRegisterType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a type of register';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Serial Number',
                        controller: _serialnumController,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int?>(
                        value: _selecteduser,
                        decoration: InputDecoration(
                          labelText: 'Notify By',
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
                        items: users!.map((Map<String, dynamic> user) {
                          return DropdownMenuItem<int>(
                            value: user['id'],
                            child: Text(user['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            print('Selected value: $value');
                            _selecteduser = value;
                          });
                        },
                        // validator: (value) {
                        //   if (value == null) {
                        //     return 'Please select a type of register';
                        //   }
                        //   return null;
                        // },
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Date In',
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
                                  onPressed: () => {
                                    //_selectDate(context)
                                  },
                                ),
                              ),
                              readOnly: true,
                              //onTap: () => _selectDate(context),
                              controller: TextEditingController(
                                text: _selectedDate == null
                                    ? ''
                                    : _selectedDate!
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                              ),
                              validator: (value) {
                                if (_selectedDate == null) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Time',
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
                                  icon: const Icon(Icons.access_time),
                                  onPressed: () => {
                                    //_selectTime(context)
                                  },
                                ),
                              ),
                              readOnly: true,
                              //onTap: () => _selectTime(context),
                              controller: TextEditingController(
                                text: _selectedTime == null
                                    ? ''
                                    : _formatTime(_selectedTime!,
                                        forDisplay: true),
                              ),
                              validator: (value) {
                                if (_selectedTime == null) {
                                  return 'Please select a time';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                                            .grey), // Replace borderColor with actual color
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<int?>(
                                    child: Text(businessTypeId == 27
                                        ? 'Select Company Name'
                                        : 'Select Stock Place'),
                                    value: null, // Representing a null value
                                  ),
                                  ...stockPlaceList
                                      .map((sp) => DropdownMenuItem<int?>(
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
                      Autocomplete<String>(
                        initialValue: TextEditingValue(text: _nameController!),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return ledgers!
                              .map((item) => item['name'] as String)
                              .where((description) => description
                                  .toLowerCase()
                                  .contains(
                                      textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selectedItem) {
                          setState(() {
                            _nameController = selectedItem;
                            _showClearIcon = true;
                          });
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController controller,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: (value) {
                              setState(() {
                                _nameController = value;
                                _showClearIcon = true;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Name Of Party',
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
                              suffixIcon: _showClearIcon
                                  ? IconButton(
                                      onPressed: () {
                                        controller.clear();
                                        onClearLedger();
                                      },
                                      icon: Icon(
                                          color: Colors.black, Icons.close),
                                    )
                                  : null,
                            ),
                            validator: (value) {
                              if (_nameController == null ||
                                  _nameController!.isEmpty) {
                                return 'Please select Party';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      // _buildTextField('Name Of Party',
                      //     controller: _nameController, isRequired: true),
                      const SizedBox(height: 16),
                      _buildTextField('Enter Challan No.',
                          controller: _challanController),
                      const SizedBox(height: 16),
                      _buildTextField('Enter Bill No.',
                          controller: _billController),
                      const SizedBox(height: 16),
                      Autocomplete<String>(
                        initialValue: TextEditingValue(text: _itemDescription!),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return items!
                              .map((item) => item['nm'] as String)
                              .where((description) => description
                                  .toLowerCase()
                                  .contains(
                                      textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selectedItem) {
                          setState(() {
                            _showClearIconItem = true;
                            _itemDescription = selectedItem;
                          });
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController controller,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              suffixIcon: _showClearIconItem
                                  ? IconButton(
                                      onPressed: () {
                                        controller.clear();
                                        setState(() {
                                          _showClearIconItem = false;
                                        });
                                      },
                                      icon: Icon(
                                          color: Colors.black, Icons.close),
                                    )
                                  : null,
                              labelText: 'Select Item Description',
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
                            // validator: (value) {
                            //   if (_itemDescription == null ||
                            //       _itemDescription!.isEmpty) {
                            //     return 'Please select an item';
                            //   }
                            //   return null;
                            // },
                            onFieldSubmitted: (String value) {
                              setState(() {
                                _itemDescription = value;
                                _showClearIconItem = value.isNotEmpty;
                              });
                            },
                            onChanged: (String value) {
                              setState(() {
                                _itemDescription = value;
                                _showClearIconItem = value.isNotEmpty;
                              });
                            },
                            onEditingComplete: () {
                              // This ensures that when the user clicks out of the TextField,
                              // the current value is saved in _itemDescription
                              setState(() {
                                _itemDescription = controller.text;
                                _showClearIconItem = controller.text.isNotEmpty;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField('Document Weight',
                                  controller: _docWeightController)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField('Vehicle No.',
                                  controller: _vehicleNoController)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Contact No. of Person',
                          controller: _contactPersonController),
                      const SizedBox(height: 16),
                      _buildTextField('Contact of Person',
                          controller: _contactController),
                      const SizedBox(height: 16),
                      _buildTextField('Enter Note Here (If Any)',
                          controller: _noteController, maxLines: 3),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            if (pickedFile != null) {
                              setState(() {
                                _selectedImage = File(pickedFile.path);
                              });

                              final bytes =
                                  await File(pickedFile.path).readAsBytes();
                              final base64Image = base64Encode(bytes);

                              setState(() {
                                _base64Image = base64Image;
                              });
                            }
                          },
                          child: Container(
                            height: 150,
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
                                  child: _selectedImage == null
                                      ? Image.asset(
                                          'assets/icons/addphoto.png',
                                          width: 24,
                                          height: 24,
                                        )
                                      : Image.file(
                                          _selectedImage!,
                                          width: 57,
                                          height: 57,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                const Text('Upload Photo',
                                    style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: abs_blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText,
      {TextEditingController? controller,
      bool isRequired = false,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
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
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}

class RegisterType {
  final int id;
  final String type;

  RegisterType({required this.id, required this.type});
}
