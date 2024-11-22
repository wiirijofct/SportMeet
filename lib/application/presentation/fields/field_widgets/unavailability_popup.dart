import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class UnavailabilityPopup extends StatefulWidget {
  final TextEditingController reasonController;
  final Function(List<DateTime>) onDatesSelected;

  UnavailabilityPopup({required this.reasonController, required this.onDatesSelected});

  @override
  _UnavailabilityPopupState createState() => _UnavailabilityPopupState();
}

class _UnavailabilityPopupState extends State<UnavailabilityPopup> {
  List<DateTime> selectedDates = [];
  Map<DateTime, String> unavailabilityReasons = {};
  DateTime focusedMonth = DateTime.now();

  void openUnavailabilityPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Unavailability",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    TableCalendar(
                      focusedDay: focusedMonth,
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      calendarFormat: CalendarFormat.month,
                      selectedDayPredicate: (day) {
                        return selectedDates.contains(day);
                      },
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        leftChevronIcon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey.shade800,
                        ),
                        rightChevronIcon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          if (selectedDates.contains(selectedDay)) {
                            selectedDates.remove(selectedDay);
                          } else {
                            selectedDates.add(selectedDay);
                          }
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          focusedMonth = focusedDay;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Reason:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: widget.reasonController,
                      maxLines: 3,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Enter a reason for unavailability",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          for (var date in selectedDates) {
                            unavailabilityReasons[date] = widget.reasonController.text;
                          }
                          widget.onDatesSelected(selectedDates);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Unavailability set for: ${selectedDates.map((date) => "${date.day}/${date.month}/${date.year}").join(', ')}",
                              ),
                              backgroundColor: Colors.blue.shade600,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        ),
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        openUnavailabilityPopup(context);
      },
      child: Text("Set Unavailability"),
    );
  }
}