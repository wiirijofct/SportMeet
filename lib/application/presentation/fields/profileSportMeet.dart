import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/input_label.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/text_field.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/schedule_popup.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/unavailability_popup.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/upload_images.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/contacts.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/hourly_price.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/description.dart';
import 'package:sport_meet/application/presentation/fields/field_widgets/register_button.dart';


class ProfileSportMeet extends StatefulWidget {
  @override
  _ProfileSportMeetState createState() => _ProfileSportMeetState();
}

class _ProfileSportMeetState extends State<ProfileSportMeet> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  String _selectedTime = "00:00";

  final List<String> sportsOptions = [
    'football',
    'pool',
    'padel',
    'tennis',
    'basketball',
  ];

  Map<String, Map<String, String>> schedule = {
    'Monday': {'Opens': '', 'Closes': ''},
    'Tuesday': {'Opens': '', 'Closes': ''},
    'Wednesday': {'Opens': '', 'Closes': ''},
    'Thursday': {'Opens': '', 'Closes': ''},
    'Friday': {'Opens': '', 'Closes': ''},
    'Saturday': {'Opens': '', 'Closes': ''},
    'Sunday': {'Opens': '', 'Closes': ''},
  };

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UploadImages(),
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
                      InputLabel("Field Name"),
                      SizedBox(height: 10),
                      CustomTextField(hint: "Enter the field name"),
                    ],
                  ),
                ),
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
                      InputLabel( "Sport"),
                      SizedBox(height: 10),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return sportsOptions;
                          }
                          return sportsOptions.where((String option) {
                            return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          _sportController.text = selection;
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldTextEditingController,
                            FocusNode fieldFocusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: fieldFocusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              hintText: "Select or type a sport",
                              hintStyle:
                                  TextStyle(color: Colors.grey.shade600),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade600),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade600),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.blue.shade600, width: 2),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Contacts(),
              SizedBox(height: 20),
              HourlyPrice(),
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
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Description(),
              SizedBox(height: 30),
              RegisterButton(
                sportController: _sportController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}