class Reservation {
  final String reservationId;
  final String fieldId;
  final String sport;
  final String date;
  final String time;
  final String teamAvailability;
  final String creatorName;
  final String creatorGender;
  final int creatorAge;
  final int slotsAvailable;
  final int maxSlots;
  final String creatorImagePath;

  Reservation({
    required this.reservationId,
    required this.fieldId,
    required this.sport,
    required this.date,
    required this.time,
    required this.teamAvailability,
    required this.creatorName,
    required this.creatorGender,
    required this.creatorAge,
    required this.slotsAvailable,
    required this.maxSlots,
    required this.creatorImagePath,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      reservationId: json['reservationId'],
      fieldId: json['fieldId'],
      sport: json['sport'],
      date: json['date'],
      time: json['time'],
      teamAvailability: json['teamAvailability'],
      creatorName: json['creatorName'],
      creatorGender: json['creatorGender'],
      creatorAge: json['creatorAge'],
      slotsAvailable: json['slotsAvailable'],
      maxSlots: json['maxSlots'],
      creatorImagePath: json['creatorImagePath'],
    );
  }
}
