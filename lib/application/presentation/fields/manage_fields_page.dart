import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_meet/application/presentation/fields/field_page.dart';
import 'package:sport_meet/application/presentation/fields/register_field_page.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/widgets/field_card.dart';
import 'package:latlong2/latlong.dart' as latlong;

class ManageFieldsPage extends StatefulWidget {
  const ManageFieldsPage({Key? key}) : super(key: key);

  @override
  State<ManageFieldsPage> createState() => _ManageFieldsPageState();
}

class _ManageFieldsPageState extends State<ManageFieldsPage> {
  final String _mapboxAccessToken =
      'pk.eyJ1Ijoid2lpcmlqbyIsImEiOiJjbTNybjNnYzIwNmdxMmlxd2llNjZkZmxuIn0.FQXiE9Hd2hnCVvTLwMnxCQ';

  latlong.LatLng? selectedLocation;
  String? streetName;
  List<Map<String, dynamic>> ownedFields = [];

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
            await _getUserOwnedFields(loggedInUser['id']);
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

    return fields
        .where((field) => field['ownerId'].toString() == userId)
        .map((field) => field as Map<String, dynamic>)
        .toList();
  }

  Future<String?> _fetchStreetName(double latitude, double longitude) async {
    final String url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$_mapboxAccessToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['features'] != null && data['features'].isNotEmpty) {
          return data['features'][0]['place_name'];
        } else {
          return 'Unnamed Street';
        }
      } else {
        print('Error fetching street name: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching street name: $e');
      return null;
    }
  }

  void _onMapTapped(latlong.LatLng position) async {
    setState(() {
      selectedLocation = position;
    });

    final street =
        await _fetchStreetName(position.latitude, position.longitude);
    setState(() {
      streetName = street ?? 'Unnamed Street';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Fields')),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(
                  10.0), // Gap/offset relative to the sides of the screen
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.blueAccent,
                    width: 2.0), // Border color and width
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: latlong.LatLng(
                      38.660913206, -9.20339502), // Default location
                  initialZoom: 16.0,
                  onTap: (tapPosition, point) {
                    _onMapTapped(point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token={accessToken}",
                    additionalOptions: {
                      'accessToken': _mapboxAccessToken,
                    },
                  ),
                  if (selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLocation!,
                          width: 80.0,
                          height: 80.0,
                          child: const Icon(Icons.location_on),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Selected Location:\n'
                'Latitude: ${selectedLocation!.latitude}\n'
                'Longitude: ${selectedLocation!.longitude}\n'
                'Street: ${streetName ?? "Fetching..."}',
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: ownedFields.length,
              itemBuilder: (context, index) {
                final field = ownedFields[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FieldPage(
                          fieldId: field['fieldId'] ?? '',
                          fieldName: field['name'] ?? '',
                          location: field['location'] ?? '',
                          imagePath: field['images'] != null &&
                                  field['images'].isNotEmpty
                              ? field['images'][0]
                              : '',
                          schedule: field['schedule'] ?? {},
                          contactEmail: field['contact'] != null
                              ? field['contact']['email'] ?? ''
                              : '',
                          contactPhone: field['contact'] != null
                              ? field['contact']['phone'] ?? ''
                              : '',
                          pricing: field['isPublic'] == true
                              ? 'Free'
                              : field['pricing'] ?? '',
                        ),
                      ),
                    );
                  },
                  child: FieldCard(
                    sport: field['sport'] ?? '',
                    name: field['name'] ?? '',
                    location: field['location'] ?? '',
                    schedule: field['schedule'] ?? {},
                    isPublic: field['isPublic'] ?? false,
                    imagePath:
                        field['images'] != null && field['images'].isNotEmpty
                            ? field['images'][0]
                            : '',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 20.0), // Offset relative to the bottom of the screen
            child: ElevatedButton(
              onPressed: () {
                if (selectedLocation != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return RegisterFieldPage(
                        coordinates: selectedLocation!,
                        streetName: streetName,
                      );
                    }),
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
          ),
        ],
      ),
    );
  }
}
