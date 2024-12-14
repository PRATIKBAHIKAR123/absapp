import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final TextStyle inter400 = GoogleFonts.inter(
  color: Color.fromRGBO(129, 129, 129, 1),
  fontWeight: FontWeight.w400,
  fontSize: 12,
);

final TextStyle inter11400 = GoogleFonts.inter(
  color: Color.fromRGBO(129, 129, 129, 1),
  fontWeight: FontWeight.w400,
  fontSize: 11,
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

final TextStyle inter_13_500 = GoogleFonts.inter(
  color: Color.fromRGBO(0, 0, 0, 1),
  fontWeight: FontWeight.w500,
  fontSize: 13,
);

final TextStyle inter700 = GoogleFonts.inter(
  color: Color.fromRGBO(35, 35, 35, 1),
  fontWeight: FontWeight.w700,
  fontSize: 14,
);

final TextStyle inter600 = GoogleFonts.inter(
  color: Color.fromRGBO(35, 35, 35, 1),
  fontWeight: FontWeight.w600,
  fontSize: 13,
);

const TextStyle urbanistTextStyle = TextStyle(
  fontSize: 30,
  color: Color(0xFF00AFEF),
  fontFamily: 'Urbanist',
  fontWeight: FontWeight.w700,
);

const TextStyle listTitle = TextStyle(
  fontSize: 18,
  color: abs_blue,
  fontFamily: 'Urbanist',
  fontWeight: FontWeight.w600,
);

const Color abs_blue = Color.fromRGBO(0, 176, 232, 1);

const Color abs_grey = Color.fromRGBO(155, 155, 155, 1);

final Image searchIcon = Image.asset(
  'assets/icons/search.png',
  width: 18,
  height: 18,
);

final Padding docdownloadicn = Padding(
    padding: const EdgeInsets.all(24),
    child: Image.asset(
      'assets/icons/docdblu.png',
      width: 24,
      height: 24,
    ));
