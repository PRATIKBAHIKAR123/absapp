import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomDropdownSearch extends StatelessWidget {
  final List<String> items;
  final String labelText;
  final Color thumbColor;
  final ValueChanged<String?> onChanged;

  const CustomDropdownSearch({
    Key? key,
    required this.items,
    required this.labelText,
    required this.thumbColor,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: items,
      popupProps: PopupProps.menu(
        scrollbarProps: ScrollbarProps(thumbColor: thumbColor),
        fit: FlexFit.loose,
        showSearchBox: true,
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
