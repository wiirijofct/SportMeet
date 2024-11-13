import 'package:flutter/material.dart';

class CenteredStretch extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  const CenteredStretch(
      {super.key, required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth), child: child));
  }
}
