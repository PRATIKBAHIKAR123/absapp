import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/styles.dart';

class SearchLedger extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Function(Map<String, dynamic>)? onledgerSelects;
  final Function? onClear;
  Map<String, dynamic>? ledgerFilter;
  final String? ledgerLabel;
  final bool isRequired;
  final String? Function(Map<String, dynamic>?)? validator;

  SearchLedger({
    Key? key,
    required this.onTextChanged,
    this.onledgerSelects,
    this.onClear,
    this.ledgerFilter,
    this.ledgerLabel,
    this.isRequired = false,
    this.validator,
  }) : super(key: key);

  @override
  State<SearchLedger> createState() => SearchLedgerState();
}

class SearchLedgerState extends State<SearchLedger> {
  final borderColor = Colors.grey.shade300;
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;
  late FocusNode myfocusNode;
  List<Map<String, dynamic>>? groups = [];
  List<Map<String, dynamic>>? ledgers = [];

  @override
  void initState() {
    super.initState();
    print('ledgerFilter:${widget.ledgerFilter}');
    getGroups();
    getLedgers();
    _textEditingController.addListener(() {
      setState(() {
        _showClearIcon = _textEditingController.text.isNotEmpty;
      });
      widget.onClear?.call();
    });
  }

  focusLedgerField() {
    myfocusNode.requestFocus(); // Call this method to focus
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void updateFilter(Map<String, dynamic> Filter) {
    setState(() {
      widget.ledgerFilter = Filter;
    });
  }

  getLedgers() async {
    print('ledgerlistFilter: ${widget.ledgerFilter}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');

    if (ledgerList != null) {
      // Create a map of group ID to group name for quick lookup
      Map<int, String> groupMap = {}; // Use int for group ID since it's numeric
      for (var group in groups!) {
        groupMap[group['id']] =
            group['name']; // Store id as key and name as value
      }

      print('Group Map: $groupMap'); // Debug print to see the group map

      // Load ledgers
      ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      // Print ledgers for debugging
      print('Initial Ledgers: $ledgers');

      // Optionally filter ledgers based on the selected groups
      if (widget.ledgerFilter != null &&
          widget.ledgerFilter!['groups'].length > 0) {
        ledgers = ledgers!
            .where((ledger) =>
                widget.ledgerFilter!['groups'].contains(ledger['group_ID']))
            .toList();
        print('Filtered Ledgers: $ledgers');
      }

      // Add groupName to each ledger based on group_ID
      for (var ledger in ledgers!) {
        ledger['groupName'] =
            groupMap[ledger['group_ID']] ?? 'Unknown'; // Set groupName
      }
    }

    setState(() {}); // Trigger a rebuild to update the UI
  }

  getGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? groupList = prefs.getStringList('group-list');
    if (groupList != null) {
      groups = groupList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
  }

  onClearLedger() {
    _textEditingController.clear();
    widget.onledgerSelects?.call({});
    setState(() {
      _showClearIcon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return ledgers!.where((ledger) {
              return ledger['name']
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['name'],
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            _textEditingController = textEditingController;
            myfocusNode = focusNode;
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (text) {
                print('Text field value changed: $text');
                widget.onTextChanged(text);
                setState(() {
                  _showClearIcon = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                focusNode.unfocus();
              },
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.search),
                ),
                suffixIcon: _showClearIcon
                    ? IconButton(
                        onPressed: () {
                          onClearLedger();
                        },
                        icon: Icon(color: Colors.black, Icons.close),
                      )
                    : null,
                contentPadding: const EdgeInsets.all(13),
                labelText:
                    (widget.ledgerLabel == '' || widget.ledgerLabel == null)
                        ? 'Search Your Ledger'
                        : '${widget.ledgerLabel}',
                labelStyle: SearchLedger.labelStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: abs_blue),
                ),
              ),
              maxLines: 1,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<Map<String, dynamic>> onSelected,
              Iterable<Map<String, dynamic>> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                child: Container(
                  height: 400,
                  width: 350,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), //color of shadow
                        spreadRadius: 5, //spread radius
                        blurRadius: 7, // blur radius
                        offset: Offset(0, 2), // changes position of shadow
                        //first paramerter of offset is left-right
                        //second parameter is top to down
                      ),
                      //you can set more BoxShadow() here
                    ],
                    color: Colors.white,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> option =
                          options.elementAt(index);
                      return ListTile(
                        title: Text(option['name']),
                        subtitle:
                            Text(option['address'] ?? 'No address available'),
                        trailing: Text(option['groupName'] ?? ''),
                        onTap: () {
                          onSelected(option);
                          print('Selected: ${option['name']}');
                          widget.onledgerSelects?.call(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class SearchLedger2 extends StatefulWidget {
  static const labelStyle =
      TextStyle(fontSize: 14, color: Color.fromRGBO(160, 160, 160, 1));
  final Function(String) onTextChanged;
  final Map<String, dynamic>? ledgerFilter;
  final Function(Map<String, dynamic>)? onledgerSelects;

  const SearchLedger2(
      {super.key,
      required this.onTextChanged,
      this.ledgerFilter,
      this.onledgerSelects});

  @override
  State<SearchLedger2> createState() => _SearchLedgerState2();
}

class _SearchLedgerState2 extends State<SearchLedger2> {
  TextEditingController _textEditingController = TextEditingController();
  bool _showClearIcon = false;

  final borderColor = Colors.grey.shade300;
  final TextStyle hintStyle = GoogleFonts.plusJakartaSans(
    color: Color.fromRGBO(160, 160, 160, 1),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  late ScrollController _scrollController;
  List<Map<String, dynamic>>? groups = [];
  List<Map<String, dynamic>>? ledgers = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    getGroups();
    getLedgers();
    _textEditingController.addListener(() {
      setState(() {
        _showClearIcon = _textEditingController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  getLedgers() async {
    print('ledgerlistFilter: ${widget.ledgerFilter}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ledgerList = prefs.getStringList('ledger-list');

    if (ledgerList != null) {
      // Create a map of group ID to group name for quick lookup
      Map<int, String> groupMap = {}; // Use int for group ID since it's numeric
      for (var group in groups!) {
        groupMap[group['id']] =
            group['name']; // Store id as key and name as value
      }

      print('Group Map: $groupMap'); // Debug print to see the group map

      // Load ledgers
      ledgers = ledgerList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();

      // Print ledgers for debugging
      print('Initial Ledgers: $ledgers');

      // Optionally filter ledgers based on the selected groups
      if (widget.ledgerFilter != null &&
          widget.ledgerFilter!['groups'].length > 0) {
        ledgers = ledgers!
            .where((ledger) =>
                widget.ledgerFilter!['groups'].contains(ledger['group_ID']))
            .toList();
        print('Filtered Ledgers: $ledgers');
      }

      // Add groupName to each ledger based on group_ID
      for (var ledger in ledgers!) {
        ledger['groupName'] =
            groupMap[ledger['group_ID']] ?? ''; // Set groupName
      }
    }

    setState(() {}); // Trigger a rebuild to update the UI
  }

  getGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? groupList = prefs.getStringList('group-list');
    if (groupList != null) {
      groups = groupList
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    }
    setState(() {}); // Trigger a rebuild to update the UI
  }

  onClearLedger() {
    _textEditingController.clear();
    widget.onledgerSelects?.call({});
    setState(() {
      _showClearIcon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return ledgers!.where((ledger) {
              return ledger['name']
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['name'],
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            _textEditingController = textEditingController;
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (text) {
                print('Text field value changed: $text');
                widget.onTextChanged(text);
                setState(() {
                  _showClearIcon = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                focusNode.unfocus();
              },
              decoration: InputDecoration(
                constraints:
                    BoxConstraints(minHeight: 53, maxHeight: 53, maxWidth: 348),
                // prefixIcon: Padding(
                //   padding: EdgeInsets.all(15),
                //   child: Image.asset(
                //     'assets/icons/search.png',
                //     width: 18,
                //     height: 18,
                //   ),
                // ),
                suffixIcon: _showClearIcon
                    ? IconButton(
                        onPressed: () {
                          onClearLedger();
                        },
                        icon: Icon(color: Colors.black, Icons.close),
                      )
                    : null,
                contentPadding: EdgeInsets.all(13),
                hintText: 'Search Ledger',
                hintStyle: hintStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide:
                      BorderSide(color: Color.fromRGBO(211, 211, 211, 1)),
                ),
              ),
              maxLines: 1,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<Map<String, dynamic>> onSelected,
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
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> option =
                              options.elementAt(index);
                          return ListTile(
                            title: Text(option['name']),
                            trailing: Text(option['groupName'] ?? ''),
                            subtitle: Column(
                              children: [
                                Text(
                                    option['address'] ?? 'No address available')
                              ],
                            ),
                            onTap: () {
                              onSelected(option);
                              print('Selected: ${option['name']}');
                              widget.onledgerSelects?.call(option);
                            },
                          );
                        },
                      ),
                    )),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
