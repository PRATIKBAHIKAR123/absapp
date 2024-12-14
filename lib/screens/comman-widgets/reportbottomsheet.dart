import 'package:abs/global/styles.dart';
import 'package:flutter/material.dart';

Widget reportsBottomSheet(opening, running) {
  const TextStyle cardcontent = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.bold,
  );
  return Container(
    height: 95,
    color: abs_blue,
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            Text('Opening :', style: cardcontent),
            Text(
              '$opening',
              style: cardcontent,
            )
          ],
        ),
        Row(
          children: [
            Text('Running :', style: cardcontent),
            Text(
              '$running',
              style: cardcontent,
            )
          ],
        )
      ],
    ),
  );
}
