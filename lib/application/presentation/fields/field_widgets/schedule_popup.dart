import 'package:flutter/material.dart';

class SchedulePopup extends StatefulWidget {
  final Map<String, dynamic> schedule;

  SchedulePopup({required this.schedule});

  @override
  _SchedulePopupState createState() => _SchedulePopupState();
}

class _SchedulePopupState extends State<SchedulePopup> {
  Map<String, bool> closedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  void openScheduleHourPopup(BuildContext context, String day, String type, StateSetter parentSetState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select $type for $day",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 250,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 24,
                    itemBuilder: (BuildContext context, int index) {
                      String time = "${index.toString().padLeft(2, '0')}:00";
                      return ListTile(
                        title: Text(
                          time,
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                        onTap: () {
                          parentSetState(() {
                            widget.schedule[day]![type] = time;
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("$type for $day set to $time"),
                              backgroundColor: Colors.blue.shade600,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void openScheduleDayPopup(BuildContext context) {
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
                  children: [
                    Text(
                      "Schedule",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: widget.schedule.keys.map((day) {
                        Color dayColor = (day == 'Saturday' || day == 'Sunday')
                            ? Colors.blue.shade800
                            : Colors.black;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                  },
                                  border: TableBorder.all(
                                    color: Colors.black,
                                    style: BorderStyle.solid,
                                    width: 1,
                                  ),
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              day,
                                              style: TextStyle(
                                                color: dayColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        closedDays[day]!
                                            ? TableCell(
                                                verticalAlignment: TableCellVerticalAlignment.middle,
                                                child: Center(
                                                  child: Text(
                                                    "Closed!",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  openScheduleHourPopup(context, day, 'Opens', setState);
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.black),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      widget.schedule[day]!['Opens']!.isEmpty ? "Not set" : widget.schedule[day]!['Opens']!,
                                                      style: TextStyle(
                                                        color: widget.schedule[day]!['Opens']!.isEmpty ? Colors.grey : Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        closedDays[day]!
                                            ? TableCell(
                                                verticalAlignment: TableCellVerticalAlignment.middle,
                                                child: Center(
                                                  child: Text(
                                                    "Closed!",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  openScheduleHourPopup(context, day, 'Closes', setState);
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.black),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      widget.schedule[day]!['Closes']!.isEmpty ? "Not set" : widget.schedule[day]!['Closes']!,
                                                      style: TextStyle(
                                                        color: widget.schedule[day]!['Closes']!.isEmpty ? Colors.grey : Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    closedDays[day] = !closedDays[day]!;
                                    if (closedDays[day]!) {
                                      widget.schedule[day]!['Opens'] = 'Closed!';
                                      widget.schedule[day]!['Closes'] = 'Closed!';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("$day is now closed."),
                                          backgroundColor: Colors.red.shade600,
                                        ),
                                      );
                                    } else {
                                      widget.schedule[day]!['Opens'] = '';
                                      widget.schedule[day]!['Closes'] = '';
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("$day is now open."),
                                          backgroundColor: Colors.green.shade600,
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: closedDays[day]! ? Colors.red.shade200 : Colors.green.shade200,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      closedDays[day]! ? Icons.close : Icons.check,
                                      color: closedDays[day]! ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
        openScheduleDayPopup(context);
      },
      child: Text("Set Schedule"),
    );
  }
}