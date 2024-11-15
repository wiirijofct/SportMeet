import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sport_meet/application/data/entity/field.dart';
import 'package:sport_meet/application/data/entity/reservation.dart';

class DataLoader {
  Future<List<Field>> loadFields() async {
    final String response = await rootBundle.loadString('assets/data/fields.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Field.fromJson(json)).toList();
  }

  Future<List<Reservation>> loadReservations() async {
    final String response = await rootBundle.loadString('assets/data/reservations.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Reservation.fromJson(json)).toList();
  }
}
