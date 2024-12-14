import 'package:abs/global/styles.dart';
import 'package:abs/global/utils.dart';
import 'package:flutter/material.dart';

Widget commanBottomSheet(List<Map<String, String>> totalData) {
  const TextStyle cardcontent = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
  );

  return ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: 200, // Set a maximum height for the container
    ),
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
                      key == 'Total Rows'
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
