import 'dart:math';

import 'package:ecotrecko/login/themes/dark_theme.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoalCard extends StatelessWidget {
  final Map<String, dynamic>? goal;
  final void Function() onPressed;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: min(width * 0.9, 500),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            elevation: 3,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: goal == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal!['title'],
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text(goal!['subtitle'],
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ]))),
    );
  }
}
