import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RegisterFieldPage extends StatelessWidget {
  final LatLng coordinates;
  final String? streetName;

  const RegisterFieldPage({Key? key, required this.coordinates, this.streetName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Field')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: '${coordinates.latitude}, ${coordinates.longitude}',
              decoration: const InputDecoration(labelText: 'Coordinates'),
              readOnly: true,
            ),
            TextFormField(
              initialValue: streetName ?? 'N/A',
              decoration: const InputDecoration(labelText: 'Street Name'),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logic to save the field with coordinates
              },
              child: const Text('Save Field'),
            ),
          ],
        ),
      ),
    );
  }
}
