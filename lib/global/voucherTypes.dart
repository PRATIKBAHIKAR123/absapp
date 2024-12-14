void resolveValuesForType(String type, String action) {
  String breadcrumbTitle1 = 'Voucher';
  String breadcrumbTitle2 = '';
  String pageTitle = '';
  String breadcrumbTitle3 = '';
  String lblbillNo = '';
  List<int> createPermission = [];
  List<int> utilityPermission = [];
  int editPermission = 0;
  int deletePermission = 0;
  int viewPermission = 0;

  if (type == 'receipt-voucher') {
    breadcrumbTitle2 = 'Receipt Voucher';
    createPermission = [140];
    utilityPermission = [142];
    editPermission = 139;
    deletePermission = 141;
    viewPermission = 138;

    if (action == 'list') {
      pageTitle = 'Voucher Receipt Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'Rec.Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Receipt Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'Rec.Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Receipt Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'Rec.Voucher No.';
    }
  } else if (type == 'payment-voucher') {
    breadcrumbTitle2 = 'Payment Voucher';
    createPermission = [134];
    utilityPermission = [136];
    editPermission = 133;
    deletePermission = 135;
    viewPermission = 132;

    if (action == 'list') {
      pageTitle = 'Payment Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'Pay.Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Payment Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'Pay.Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Payment Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'Pay.Voucher No.';
    }
  } else if (type == 'contra-voucher') {
    breadcrumbTitle2 = 'Contra Voucher';
    createPermission = [152];
    utilityPermission = [154];
    editPermission = 151;
    deletePermission = 153;
    viewPermission = 150;

    if (action == 'list') {
      pageTitle = 'Contra Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'Contra Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Contra Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'Contra Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Contra Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'Contra Voucher No.';
    }
  } else if (type == 'journal-voucher') {
    breadcrumbTitle2 = 'Journal Voucher';
    createPermission = [146];
    utilityPermission = [148];
    editPermission = 145;
    deletePermission = 147;
    viewPermission = 144;

    if (action == 'list') {
      pageTitle = 'Journal Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'J.Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Journal Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'J.Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Journal Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'J.Voucher No.';
    }
  } else if (type == 'purchase-voucher') {
    breadcrumbTitle2 = 'Purchase Voucher';
    createPermission = [98];
    utilityPermission = [100];
    editPermission = 97;
    deletePermission = 99;
    viewPermission = 96;

    if (action == 'list') {
      pageTitle = 'Purchase Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'Purchase Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Purchase Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'Purchase Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Purchase Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'Purchase Voucher No.';
    }
  } else if (type == 'credit-note') {
    breadcrumbTitle2 = 'Credit Note Voucher';
    createPermission = [68];
    utilityPermission = [70];
    editPermission = 67;
    deletePermission = 69;
    viewPermission = 66;

    if (action == 'list') {
      pageTitle = 'Credit Note Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'Credit Note Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Credit Note Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'Credit Note Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Credit Note Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'Credit Note Voucher No.';
    }
  } else if (type == 'debit-note') {
    breadcrumbTitle2 = 'Debit Note Voucher';
    createPermission = [104];
    utilityPermission = [106];
    editPermission = 103;
    deletePermission = 105;
    viewPermission = 102;

    if (action == 'list') {
      pageTitle = 'Debit Note Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'Debit Note Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Debit Note Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'Debit Note Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Debit Note Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'Debit Note Voucher No.';
    }
  } else if (type == 'sales-voucher') {
    breadcrumbTitle2 = 'Sales Voucher';
    createPermission = [62];
    utilityPermission = [64];
    editPermission = 61;
    deletePermission = 63;
    viewPermission = 60;

    if (action == 'list') {
      pageTitle = 'Sales Voucher';
      breadcrumbTitle3 = 'List';
      lblbillNo = 'Sales Voucher No.';
    } else if (action == 'new') {
      pageTitle = 'Create New Sales Voucher';
      breadcrumbTitle3 = 'New';
      lblbillNo = 'Sales Voucher No.';
    } else if (action == 'edit') {
      pageTitle = 'Sales Voucher Info';
      breadcrumbTitle3 = 'Edit';
      lblbillNo = 'Sales Voucher No.';
    }
  }

  // Use these variables as needed within your Flutter app.
}
