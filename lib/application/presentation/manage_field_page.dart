import 'package:flutter/material.dart';

class ManageFieldPage extends StatelessWidget {
  const ManageFieldPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Field'),
      ),
      body: Center(
        child: const Text('Manage Field Page Content'),
      ),
    );
  }
}