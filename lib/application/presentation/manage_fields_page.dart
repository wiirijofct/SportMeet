import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_meet/application/presentation/register_field_page.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:latlong2/latlong.dart' as latlong;

class ManageFieldsPage extends StatefulWidget {
  const ManageFieldsPage({Key? key}) : super(key: key);

  @override
  State<ManageFieldsPage> createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  late MapboxMapController _mapController;
  LatLng? selectedLocation;
  String? streetName;
  List<Map<String, dynamic>> ownedFields = [];

  final String _mapboxAccessToken = 'pk.eyJ1Ijoid2lpcmlqbyIsImEiOiJjbTNxbHdrOHEwa3BwMmxzZWZzNGdheTU3In0.Wa_kq4Q8XlJmA47n342Blg';

  @override
  void initState() {
    super.initState();
    _fetchOwnedFields();
  }

  Future<void> _fetchOwnedFields() async {
    try {
      final loggedInUser = await Authentication.getLoggedInUser();
      if (loggedInUser != null) {
        List<Map<String, dynamic>> fields =
            await _getUserOwnedFields(loggedInUser['userId']);
        setState(() {
          ownedFields = fields;
        });
      }
    } catch (e) {
      print('Error fetching owned fields: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getUserOwnedFields(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fieldsJson = prefs.getString('fields');
    List<dynamic> fields = fieldsJson != null ? jsonDecode(fieldsJson) : [];

    return fields.where((field) => field['ownerId'].toString() == userId).map((field) => field as Map<String, dynamic>).toList();
  }

  void _onMapTapped(LatLng position) async {
    setState(() {
      selectedLocation = position;
    });

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          streetName = placemark.street ?? 'Unnamed Street';
        });
      } else {
        setState(() {
          streetName = 'Unnamed Street';
        });
      }
    } catch (e) {
      print('Error fetching street name: $e');
      setState(() {
        streetName = 'Error fetching street name';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Fields'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MapboxMap(
              accessToken: _mapboxAccessToken,
              onMapCreated: (MapboxMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(38.7223, -9.1393),
                zoom: 13.0,
              ),
              onMapClick: (point, latLng) {
                _onMapTapped(latLng);
                _mapController.addSymbol(
                  SymbolOptions(
                    geometry: latLng,
                    iconImage: "marker-15",
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: ownedFields.length,
              itemBuilder: (context, index) {
                final field = ownedFields[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(
                      field['images'][0],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(field['name']),
                    subtitle: Text(field['location']),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedLocation != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) {
                    return RegisterFieldPage(
                      coordinates: latlong.LatLng(
                        selectedLocation!.latitude,
                        selectedLocation!.longitude,
                      ),
                      streetName: streetName,
                    );
                    }
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a location on the map.'),
                  ),
                );
              }
            },
            child: const Text('Register New Field'),
          ),
        ],
      ),
    );
  }
}
