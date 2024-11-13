import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  final double maxWidth;
  final double gap;
  final List<Widget> children;

  const Wrapper(
      {super.key,
      required this.maxWidth,
      required this.gap,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double width = constraints.maxWidth;
      int itemsPerRow = (width ~/ maxWidth).clamp(1, 5);

      return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: gap,
          children: children.map((child) {
            return SizedBox(
              width: width / itemsPerRow,
              child: child,
            );
          }).toList());
    });
  }
}
