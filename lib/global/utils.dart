import 'dart:math';

import 'package:abs/global/appCommon.dart';
import 'package:intl/intl.dart';

String formatAmount(String amount) {
  try {
    double parsedAmount = double.parse(amount);
    final NumberFormat numberFormat = NumberFormat("#,##,##0.00", "en_IN");
    return numberFormat.format(parsedAmount);
  } catch (e) {
    return amount; // Return the original value if parsing fails
  }
}

Object formatDoubleIntoAmount(amount) {
  try {
    final NumberFormat numberFormat = NumberFormat("#,##,##0.00", "en_IN");
    return numberFormat.format(amount);
  } catch (e) {
    return amount ?? 00.0; // Return the original value if parsing fails
  }
}

String formatDateTime(String isoDateTime) {
  // Parse the ISO datetime string
  DateTime dateTime = DateTime.parse(isoDateTime);

  // Define the format you want
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');

  // Format the datetime
  String formattedDate = formatter.format(dateTime);

  return formattedDate;
}

getStateNameById(int stateID) {
  List<Map<String, dynamic>>? stateList = enStateCode;
  String stateName = '';

  var state = stateList.firstWhere((o) => o['id'] == stateID, orElse: () => {});
  if (state.isNotEmpty) {
    stateName = state['text'];
  }
  return stateName;
}

double round(double value, double precision) {
  num mod = pow(10.0, precision);
  return ((value * mod).round().toDouble() / mod);
}

Map<String, double> invoiceGridCalculations({
  required int gstType,
  required double qty,
  required double rate,
  required double disc1,
  required double disc2,
  required double disc3,
  required double ratedisc,
  required double vat,
  required double conversions,
  required double basecurrency,
  required double precision,
}) {
  // Initialize result map
  var result = {
    'amount': 0.0,
    'stdqty': 0.0,
    'stdrate': 0.0,
    'landing': 0.0,
    'cgstPer': 0.0,
    'cgstAmt': 0.0,
    'sgstPer': 0.0,
    'sgstAmt': 0.0,
    'igstPer': 0.0,
    'igstAmt': 0.0,
    'rateAfterVat': 0.0,
    'expectedMargin': 0.0,
  };

  // Process discount on rate
  double landing =
      processDiscountOnRate(rate, disc1, disc2, disc3, ratedisc, basecurrency);

  double grossAmount = qty * landing;

  // Calculate amount
  result['amount'] = round(grossAmount, precision);

  // Calculate tax amount
  var taxval = getTaxValue(gstType, vat, result['amount']!, precision);
  result['cgstPer'] = taxval['cgstPer']!;
  result['cgstAmt'] = taxval['cgstAmt']!;
  result['sgstPer'] = taxval['sgstPer']!;
  result['sgstAmt'] = taxval['sgstAmt']!;
  result['igstPer'] = taxval['igstPer']!;
  result['igstAmt'] = taxval['igstAmt']!;

  // Calculate standard quantity
  double stdqty = qty * conversions;
  result['stdqty'] = stdqty;

  // Calculate standard rate
  if (qty > 0) {
    result['stdrate'] = (qty * rate) / stdqty;
  } else {
    result['stdrate'] = 0.0;
  }

  // Calculate landing cost
  result['landing'] = landing;

  return result;
}

double processDiscountOnRate(double rate, double disc1, double disc2,
    double disc3, double ratedisc, double basecurrency) {
  double d1 = rate * (1 - (disc1 / 100));
  double d2 = d1 * (1 - (disc2 / 100));
  double d3 = d2 - disc3;
  double d4 = d3 - ratedisc;

  // Convert rate if other than base currency
  d4 = d4 * (basecurrency != 0 ? basecurrency : 1);

  return d4;
}

Map<String, double> getTaxValue(
    int gstType, double vat, double amount, double precision) {
  Map<String, double> result = {
    'cgstPer': 0.0,
    'cgstAmt': 0.0,
    'sgstPer': 0.0,
    'sgstAmt': 0.0,
    'igstPer': 0.0,
    'igstAmt': 0.0,
  };

  if (gstType == 1) {
    double gstPer = round(vat / 2, precision);
    double gstAmount = round(amount * (gstPer / 100), precision);

    result['cgstPer'] = gstPer;
    result['cgstAmt'] = gstAmount;
    result['sgstPer'] = gstPer;
    result['sgstAmt'] = gstAmount;
  } else {
    double gstAmount = round(amount * (vat / 100), precision);

    result['igstPer'] = vat;
    result['igstAmt'] = gstAmount;
  }

  return result;
}
