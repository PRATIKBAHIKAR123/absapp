import 'package:abs/global/invoiceTypes.dart';
import 'package:abs/screens/comman-widgets/emailshare-dialog.dart';
import 'package:abs/screens/comman-widgets/invoice-dialog.dart';
import 'package:abs/screens/comman-widgets/whatsappshare-dialog.dart';
import 'package:abs/screens/reports/materialRequest.dart';
import 'package:flutter/material.dart';

Future<void> showCustomPopupMenu({
  required BuildContext context,
  required Offset position,
  required String id,
  int? invType,
  Map<String, dynamic>? invoice,
  InvoiceType? invoiceType,
  //required Function(String) onSelected,
}) async {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  await showMenu(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(
        position.dx,
        position.dy,
        0,
        0,
      ),
      Offset.zero & overlay.size,
    ),
    items: [
      PopupMenuItem<String>(
        value: 'Edit',
        child: Text('Edit'),
      ),
      PopupMenuItem<String>(
        value: 'Print',
        child: Text('Print'),
      ),
      PopupMenuItem<String>(
        value: 'WhatsApp',
        child: Text('WhatsApp'),
      ),
      PopupMenuItem<String>(
        value: 'E-Mail',
        child: Text('E-Mail'),
      ),
    ],
    elevation: 8.0,
  ).then((value) {
    if (value != null) {
      switch (value) {
        case 'Edit':
          if (invoice != null && invoiceType != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MaterialRequestScreen(
                  rid: invoice['invCode'],
                  invoiceType: invoiceType,
                ),
              ),
            );
          } else {
            // Handle null invoice or invoiceType
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Invoice or InvoiceType is null')),
            );
          }

          break;
        case 'Print':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return InvoiceDialog(
                invoice: invoice,
                id: id,
                invoiceType: invoiceType,
                sessionId: '',
                invType: invType,
              );
            },
          );
          break;
        case 'WhatsApp':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return WhatsAppPopup(
                invoice: invoice,
                id: id,
                invoiceType: invoiceType,
                invType: invType,
              );
            },
          );
          break;
        case 'E-Mail':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return EMailPopup(
                invoice: invoice,
                id: id,
                invoiceType: invoiceType,
                invType: invType,
              );
            },
          );
          break;
        default:
          break;
      }
    }
  });
}
