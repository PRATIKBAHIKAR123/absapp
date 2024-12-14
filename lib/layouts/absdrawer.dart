import 'package:abs/screens/login/login.dart';
import 'package:abs/screens/masters/items/items.dart';
import 'package:abs/screens/masters/ledgers/ledgers.dart';
import 'package:abs/screens/reports/ledgerOutstandingSummeryReport.dart';
import 'package:abs/services/companyFetch.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your screens and assets as needed
import 'package:abs/global/invoiceTypes.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

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

  final TextStyle logoutTextStyle = GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: const Color.fromRGBO(208, 0, 0, 1),
  );

  // Track the currently expanded tile value
  int? _currentExpandedValue;
  int? businessTypeId;

  @override
  void initState() {
    super.initState();
    getCompanyData();
  }

  Future<void> getCompanyData() async {
    Map<String, dynamic>? currentCompany =
        await CompanyDataUtil.getCompanyFromLocalStorage();
    setState(() {
      businessTypeId = currentCompany!['businessType'];
    });
    print('businessTypeId$businessTypeId');
  }

  logOut(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
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
          // This is a ListView with ExpansionPanelList.radio
          ExpansionPanelList.radio(
            elevation: 1,
            expandedHeaderPadding: EdgeInsets.all(0),
            //radioGroupValue: _currentExpandedValue,
            children: [
              _buildExpansionPanel(
                value: 0,
                title: 'Masters',
                leadingIcon: 'assets/icons/sales.png',
                children: <Widget>[
                  _createDrawerItem(
                    text: 'Ledgers',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LedgersListScreen()),
                      );
                    },
                  ),
                  _createDrawerItem(
                    text: 'Items',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ItemsListScreen()),
                      );
                    },
                  ),
                ],
              ),
              if (businessTypeId != 27) ...[
                _buildExpansionPanel(
                  value: 1,
                  title: 'Sales',
                  leadingIcon: 'assets/icons/sales.png',
                  children: <Widget>[
                    if (businessTypeId != 31 && businessTypeId != 3) ...[
                      _createDrawerItem(
                        text: 'Sales Enquiry',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MaterialRequestSlipScreen(
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
                                builder: (context) =>
                                    const MaterialRequestSlipScreen(
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
                                builder: (context) =>
                                    const MaterialRequestSlipScreen(
                                      invoiceType: InvoiceType.salesOrder,
                                    )),
                          );
                        },
                      ),
                    ],
                    _createDrawerItem(
                      text: 'Sales Invoice',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SalesInvoiceListScreen()),
                        );
                      },
                    ),
                    if (businessTypeId == 31 || businessTypeId == 3) ...[
                      _createDrawerItem(
                        text: 'Cash Invoice',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MaterialRequestSlipScreen(
                                      invoiceType: InvoiceType.cashInvoice,
                                    )),
                          );
                        },
                      )
                    ],
                  ],
                )
              ],
              if (businessTypeId != 31 && businessTypeId != 3) ...[
                _buildExpansionPanel(
                  value: 2,
                  title: 'Purchase',
                  leadingIcon: 'assets/icons/purchase.png',
                  children: <Widget>[
                    if (businessTypeId != 27) ...[
                      _createDrawerItem(
                        text: 'Purchase Request',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MaterialRequestSlipScreen(
                                      invoiceType:
                                          InvoiceType.purchaseQuotation,
                                    )),
                          );
                        },
                      )
                    ],
                    _createDrawerItem(
                      text: 'Purchase Order',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
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
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
                                    invoiceType: InvoiceType.purchaseChallan,
                                  )),
                        );
                      },
                    ),
                    if (businessTypeId != 27) ...[
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
                      )
                    ],
                  ],
                ),
              ],
              if (businessTypeId != 31 && businessTypeId != 3) ...[
                _buildExpansionPanel(
                  value: 3,
                  title: 'Stock',
                  leadingIcon: 'assets/icons/stockicon.png',
                  children: <Widget>[
                    _createDrawerItem(
                      text: 'Material Request',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
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
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
                                      invoiceType: InvoiceType.materialIn)),
                        );
                      },
                    ),
                    _createDrawerItem(
                      text: 'Material Out',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
                                      invoiceType: InvoiceType.materialOut)),
                        );
                      },
                    ),
                    _createDrawerItem(
                      text: 'Open Stock Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
                                      invoiceType: InvoiceType.openingStock)),
                        );
                      },
                    ),
                  ],
                ),
                _buildExpansionPanel(
                  value: 4,
                  title: 'Production',
                  leadingIcon: 'assets/icons/productionicons8.png',
                  children: <Widget>[
                    if (businessTypeId == 27) ...[
                      _createDrawerItem(
                        text: 'Job Work Supplier Challan Out',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MaterialRequestSlipScreen(
                                      invoiceType:
                                          InvoiceType.jobWorkSupplierChallanOut,
                                    )),
                          );
                        },
                      ),
                      _createDrawerItem(
                        text: 'job Work Supplier Challan In',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MaterialRequestSlipScreen(
                                      invoiceType:
                                          InvoiceType.jobWorkSupplierChallanIn,
                                    )),
                          );
                        },
                      ),
                    ],
                    _createDrawerItem(
                      text: 'Ready Production Slip',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
                                    invoiceType:
                                        InvoiceType.readyProductionSlip,
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
                              builder: (context) =>
                                  const MaterialRequestSlipScreen(
                                    invoiceType: InvoiceType.consumeRawMaterial,
                                  )),
                        );
                      },
                    ),
                  ],
                ),
              ],
              if (businessTypeId != 27) ...[
                _buildExpansionPanel(
                  value: 5,
                  title: 'Accounts',
                  leadingIcon: 'assets/icons/accountsicon.png',
                  children: <Widget>[
                    _createDrawerItem(
                      text: 'Receipt Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const receiptVoucherListScreen()),
                        );
                      },
                    ),
                    _createDrawerItem(
                      text: 'Payment Voucher',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const paymentVoucherListScreen()),
                        );
                      },
                    ),
                    if (businessTypeId != 31 && businessTypeId != 3) ...[
                      _createDrawerItem(
                        text: 'Journal Voucher',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const JournalVoucherListScreen()),
                          );
                        },
                      ),
                    ]
                  ],
                )
              ],
              if (businessTypeId != 31 && businessTypeId != 3) ...[
                _buildExpansionPanel(
                  value: 6,
                  title: 'Report',
                  leadingIcon: 'assets/icons/reporticon.png',
                  children: <Widget>[
                    if (businessTypeId != 27) ...[
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
                                builder: (context) =>
                                    const LedgerOutstandingScreen()),
                          );
                        },
                      ),
                      _createDrawerItem(
                        text: 'Ledger Outstanding Summary',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LedgerOutstandingSummaryScreen()),
                          );
                        },
                      )
                    ],
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
                    if (businessTypeId != 27) ...[
                      _createDrawerItem(
                        text: 'Stock Report',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StockReportScreen()),
                          );
                        },
                      )
                    ],
                  ],
                ),
              ],
            ],
          ),
          if (businessTypeId == 27) ...[
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
            )
          ],
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    bool? result = await showConfirmationDialog(context);
                    if (result == true) {
                      // User confirmed
                      logOut(context);
                    } else {
                      // User canceled
                    }
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.exit_to_app,
                            color: Color.fromRGBO(208, 0, 0, 1)),
                        Text(
                          'Log Out',
                          style: logoutTextStyle,
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ExpansionPanelRadio _buildExpansionPanel({
    required int value,
    required String title,
    required String leadingIcon,
    required List<Widget> children,
  }) {
    return ExpansionPanelRadio(
      backgroundColor: Colors.white,
      value: value,
      canTapOnHeader: true,
      headerBuilder: (context, isExpanded) {
        return ListTile(
          leading: Image.asset(
            leadingIcon,
            width: 20,
            height: 20,
          ),
          title: Text(title, style: drawerTextStyle),
        );
      },
      body: Column(
        children: children,
      ),
    );
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
}

Future<bool?> showConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Log out', style: TextStyle(fontSize: 20)),
        content: Text(
          'Are you sure you want to Log Out?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Return true
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );
}
