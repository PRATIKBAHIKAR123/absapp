import 'package:abs/global/invoiceTypes.dart';
import 'package:abs/global/styles.dart';
import 'package:abs/screens/accounts/journalVoucher.dart';
import 'package:abs/screens/accounts/paymentVoucher.dart';
import 'package:abs/screens/accounts/receiptVoucher.dart';
import 'package:abs/screens/dashboard/dashboard.dart';
import 'package:abs/screens/purchase/purchaseinvoice/purchaseInvoiceList.dart';
import 'package:abs/screens/purchase/purchaseorder/purchaseOrderList.dart';
import 'package:abs/screens/register/registerListScreen.dart';
import 'package:abs/screens/reports/currentStockSummary.dart';
import 'package:abs/screens/reports/ledgerOutstandingReport.dart';
import 'package:abs/screens/reports/ledgerregisterreport.dart';
import 'package:abs/screens/reports/materialRequest.dart';
import 'package:abs/screens/reports/stockReport.dart';
import 'package:abs/screens/sales/salesenquiry/salesEnquiryList.dart';
import 'package:abs/screens/sales/salesorder/salesOrderList.dart';
import 'package:abs/screens/sales/salesquotation/salesQuotionList.dart';
import 'package:abs/screens/salesinvoice/salesInvoiceList.dart';
import 'package:abs/screens/stock/materialIn.dart';
import 'package:abs/screens/stock/materialOut.dart';
import 'package:abs/screens/stock/materialRequestSlip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final TextStyle drawerTextStyle = GoogleFonts.inter(
    fontSize: 14,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );

  final Image drawerIcon = Image.asset(
    'assets/icons/drawerIcon.png',
    width: 20,
    height: 20,
  );

  int? expandedTile; // To keep track of the expanded tile

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/abs-logo.png',
                  height: 64,
                  width: 154,
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                createDrawerItem(
                  icon: 'assets/icons/homeicon.png',
                  text: 'Home',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DashboardScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          buildExpansionTile(
            context: context,
            title: 'Sales',
            tileIndex: 1,
            leadingIcon: 'assets/icons/sales.png',
            tileName: 'sales',
            children: <Widget>[
              _createDrawerItem(
                text: 'Sales Enquiry',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                              invoiceType: InvoiceType.salesEnquiry,
                            )),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Sales Quotation',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                              invoiceType: InvoiceType.salesQuotation,
                            )),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Sales Order',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                              invoiceType: InvoiceType.salesOrder,
                            )),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Sales Invoice',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesInvoiceListScreen()),
                  );
                },
              ),
            ],
          ),
          buildExpansionTile(
            context: context,
            tileIndex: 2,
            title: 'Purchase',
            leadingIcon: 'assets/icons/purchase.png',
            tileName: 'purchase',
            children: <Widget>[
              _createDrawerItem(
                text: 'Purchase Order',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                              invoiceType: InvoiceType.purchaseOrder,
                            )),
                  );
                },
              ),
              _createDrawerItem(
                text: 'GRN',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                              invoiceType: InvoiceType.purchaseChallan,
                            )),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Purchase Invoice',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const PurchaseInvoiceListScreen()),
                  );
                },
              ),
            ],
          ),
          buildExpansionTile(
            context: context,
            title: 'Stock',
            tileIndex: 3,
            leadingIcon: 'assets/icons/stockicon.png',
            tileName: 'stock',
            children: <Widget>[
              _createDrawerItem(
                text: 'Material Request',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                            invoiceType: InvoiceType.materialSlip)),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Material In',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialInScreen()),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Material Out',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialOutScreen()),
                  );
                },
              ),
            ],
          ),
          buildExpansionTile(
            context: context,
            title: 'Production',
            tileIndex: 4,
            leadingIcon: 'assets/icons/productionicons8.png',
            tileName: 'production',
            children: <Widget>[
              _createDrawerItem(
                text: 'Ready Production Slip',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                              invoiceType: InvoiceType.readyProductionSlip,
                            )),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Consume Raw Material',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MaterialRequestSlipScreen(
                              invoiceType: InvoiceType.consumeRawMaterial,
                            )),
                  );
                },
              ),
            ],
          ),
          buildExpansionTile(
            context: context,
            tileIndex: 5,
            title: 'Accounts',
            leadingIcon: 'assets/icons/accountsicon.png',
            tileName: 'accounts',
            children: <Widget>[
              _createDrawerItem(
                text: 'Receipt Voucher',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const receiptVoucherListScreen()),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Payment Voucher',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const paymentVoucherListScreen()),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Journal Voucher',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const JournalVoucherListScreen()),
                  );
                },
              ),
            ],
          ),
          buildExpansionTile(
            context: context,
            tileIndex: 6,
            title: 'Report',
            leadingIcon: 'assets/icons/reporticon.png',
            tileName: 'report',
            children: <Widget>[
              _createDrawerItem(
                text: 'Ledger Register',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const LedgerRegisterReportScreen()),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Ledger Outstanding',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LedgerOutstandingScreen()),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Current Stock Summary',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const CurrentStockSummaryScreen()),
                  );
                },
              ),
              _createDrawerItem(
                text: 'Stock Report',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StockReportScreen()),
                  );
                },
              ),
            ],
          ),
          Container(
            child: Column(
              children: [
                createDrawerItem(
                  icon: 'assets/icons/registericon.png',
                  text: 'Register',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterListScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpansionTile({
    required int tileIndex,
    required BuildContext context,
    required String title,
    required String leadingIcon,
    required String tileName,
    required List<Widget> children,
  }) {
    return ExpansionTile(
        leading: Image.asset(
          leadingIcon,
          width: 20,
          height: 20,
        ),
        title: Text(title, style: drawerTextStyle),
        children: children,
        initiallyExpanded: expandedTile == tileIndex,
        onExpansionChanged: ((newState) {
          print('expandedTile$expandedTile');
          if (newState)
            setState(() {
              expandedTile = tileIndex;
            });
          else
            setState(() {
              expandedTile = -1;
            });
        }));
  }

  Widget _createDrawerItem({required String text, GestureTapCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(text, style: drawerTextStyle),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget createDrawerItem({
    required String icon,
    required String text,
    GestureTapCallback? onTap,
  }) {
    return ListTile(
      leading: Image.asset(icon, width: 20, height: 20),
      title: Text(text, style: drawerTextStyle),
      onTap: onTap,
    );
  }
}
