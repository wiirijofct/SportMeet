import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/input_label.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/schedule_popup.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/unavailability_popup.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/upload_images.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/description.dart';
import 'package:sport_meet/application/presentation/applogic/fields_service.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/field_name_input.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/sport_input.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/street_name_and_coordinates_input.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/hourly_price_input.dart';

class RegisterFieldPage extends StatefulWidget {
  final LatLng coordinates;
  final String? streetName;

  const RegisterFieldPage({Key? key, required this.coordinates, this.streetName})
      : super(key: key);

  @override
  _RegisterFieldPageState createState() => _RegisterFieldPageState();
}

class _RegisterFieldPageState extends State<RegisterFieldPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  final TextEditingController _hourlyPriceController = TextEditingController();
  final TextEditingController _fieldNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _streetNameController;
  late TextEditingController _coordinatesController;
  String _selectedTime = "00:00";
  bool isPublic = false;
  String? ownerId;
  List<String> unavailabilityDates = [];

  late List<String> sportsOptions = [];
  final FieldsService _fieldsService = FieldsService();

  Map<String, dynamic> schedule = {
    'Monday': {'Opens': '', 'Closes': ''},
    'Tuesday': {'Opens': '', 'Closes': ''},
    'Wednesday': {'Opens': '', 'Closes': ''},
    'Thursday': {'Opens': '', 'Closes': ''},
    'Friday': {'Opens': '', 'Closes': ''},
    'Saturday': {'Opens': '', 'Closes': ''},
    'Sunday': {'Opens': '', 'Closes': ''},
  };

  @override
  void initState() {
    super.initState();
    _streetNameController = TextEditingController(text: widget.streetName ?? '');
    _coordinatesController = TextEditingController(
        text: '${widget.coordinates.latitude}, ${widget.coordinates.longitude}');
    _fetchAvailableSports();
    _fetchOwnerID();
  }

  Future<void> _fetchOwnerID() async {
    final userInfo = await _fieldsService.userInfo;
    setState(() {
      ownerId = userInfo['id'];
    });
  }

  Future<void> _fetchAvailableSports() async {
    try {
      final sports = await _fieldsService.fetchAvailableSports();
      setState(() {
        sportsOptions = List<String>.from(sports);
      });
    } catch (e) {
      print('Error fetching available sports: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _validateSchedule() {
    for (var times in schedule.values) {
      if (times != false && (times['Opens'] == '' || times['Closes'] == '')) {
        return false;
      }
    }
    return true;
  }

  Future<void> _addField() async {
    if (!_formKey.currentState!.validate() || !_validateSchedule()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Owner ID not available')),
      );
      return;
    }

    // Split the street name by commas and use the first part as the location
    List<String> streetParts = _streetNameController.text.split(',');
    String location = streetParts.isNotEmpty ? streetParts[0].trim() : '';

    // Update the schedule to use false for closed days
    schedule.forEach((day, times) {
      if (times['Opens'] == 'Closed!' && times['Closes'] == 'Closed!') {
        schedule[day] = false;
      }
    });

    String id = DateTime.now().millisecondsSinceEpoch.toString();

    // Set hourly price to 0 if the field is private and no price is provided
    String hourlyPrice = isPublic
        ? 'Free'
        : (_hourlyPriceController.text.isEmpty ? '0' : _hourlyPriceController.text);

    final fieldData = {
      'id': id, // You might want to generate or fetch this ID
      'fieldId': id, // You might want to generate or fetch this ID
      'ownerId': ownerId, // Use the fetched owner ID
      'sport': _sportController.text,
      'name': _fieldNameController.text,
      'street': _streetNameController.text,
      'location': location,
      'coordinates': {
        'lat': widget.coordinates.latitude,
        'lon': widget.coordinates.longitude,
      },
      'schedule': schedule,
      'unavailability': unavailabilityDates.map((date) => _formatDate(DateTime.parse(date))).toList(), // Format unavailability dates
      'isPublic': isPublic,
      'pricing': isPublic ? 'Free' : '${hourlyPrice}€/hour',
      'contact': {
        'email': _emailController.text,
        'phone': _phoneController.text,
      },
      'description': _descriptionController.text,
      'images': ["lib/images/Gecko.png",
        "lib/images/Gecko.png"], // Add logic to handle images
    };

    try {
      await _fieldsService.addField(fieldData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Field added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add field: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register Property",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Scrollbar(
        thickness: 6,
        radius: Radius.circular(8),
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadImages(),
                SizedBox(height: 20),
                FieldNameInput(
                  controller: _fieldNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Field name cannot be empty';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                SportInput(
                  controller: _sportController,
                  sportsOptions: sportsOptions,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a sport';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                StreetNameAndCoordinatesInput(
                  streetNameController: _streetNameController,
                  coordinatesController: _coordinatesController,
                ),
                SizedBox(height: 20),
                HourlyPriceInput(
                  controller: _hourlyPriceController,
                  isPublic: isPublic,
                  onChanged: (bool? value) {
                    setState(() {
                      isPublic = value ?? false;
                      if (isPublic) {
                        _hourlyPriceController.text = "Free";
                      } else {
                        _hourlyPriceController.clear();
                      }
                    });
                  },
                ),
                SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        InputLabel("Contact Email"),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            hintText: "Enter contact email",
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade600),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade600),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.blue.shade600, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Contact email cannot be empty';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        InputLabel("Contact Phone"),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            hintText: "Enter contact phone",
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade600),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade600),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.blue.shade600, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Contact phone cannot be empty';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SchedulePopup(
                        schedule: schedule,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: UnavailabilityPopup(
                        reasonController: _reasonController,
                        onDatesSelected: (dates) {
                          setState(() {
                            unavailabilityDates = dates.map((date) => date.toIso8601String()).toList();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Description(controller: _descriptionController),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _addField,
                  child: Text('Register Field'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}