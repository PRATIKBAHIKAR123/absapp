import 'package:abs/screens/comman-widgets/comman-bottomsheet.dart';
import 'package:flutter/material.dart';

class _CommamBottomSheetDelegate extends SliverPersistentHeaderDelegate {
  final List<Map<String, String>> totalData;

  _CommamBottomSheetDelegate({required this.totalData});

  @override
  double get minExtent => 95.0;
  @override
  double get maxExtent => 95.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return commanBottomSheet(totalData);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
