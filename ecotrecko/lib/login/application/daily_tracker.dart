import 'dart:async';
import 'dart:convert';
import 'package:eventify/eventify.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ionicons/ionicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'dart:math' as math;

const String dailyTrackerPrefsName = "dailyTracker";
const String dailyTrackerLocationsPrefsName = "dailyTrackerLocations";
const String dailyTrackerTransportModePrefsName = "dailyTrackerTransportMode";
const String dailyTrackerGPSIntervalPrefsName = "dailyTrackerGPSInterval";

enum TransportMode {
  auto('Automatic', [(0, 0)], Ionicons.accessibility_outline),
  walking('Walking', [(0, 0)], Ionicons.walk_outline),
  bicycle('Bicycle', [(0, 0)], Ionicons.bicycle_outline),
  car('Car', [(0, 0.15), (20, 0.12), (40, 0.10), (60, 0.08), (80, 0.07)], Ionicons.car_outline),
  bus('Bus', [(0, 0.10), (20, 0.08), (40, 0.06), (60, 0.05)], Ionicons.bus_outline),
  train('Train', [(0, 0.04), (50, 0.03), (100, 0.02)], Ionicons.train_outline),
  plane('Plane', [(0, 0.15), (300, 0.12), (600, 0.10), (900, 0.09), (1200, 0.08), (1500, 0.07)], Ionicons.airplane_outline);

  const TransportMode(this.label, this.emissionFactors, this.icon);
  final String label;
  final List<(int, double)> emissionFactors;
  final IconData icon;

  double getEmissionFactorBy(double speed) {
    double speedKmH = speed * 3.6;

    for (int i = 1; i < emissionFactors.length; i++) {
      final emissionFactor1 = emissionFactors[i-1];
      final emissionFactor2 = emissionFactors[i];

      if (emissionFactor1.$1 >= speedKmH && speedKmH >= emissionFactor2.$1) {
        return emissionFactor1.$2;
      }
    }

    return emissionFactors.last.$2;
  }

  String toJson() => name;
  static TransportMode fromJson(String json) => values.byName(json);
}

class LocationData {
  double latitude = 0;
  double longitude = 0;
  double speed = 0;
  TransportMode transport = TransportMode.auto;
  int time = 0;

  LocationData(
      this.latitude, this.longitude, this.speed, this.transport, this.time);

  TransportMode getTransportMode() {
    if (transport != TransportMode.auto) {
      return transport;
    }

    double speedKmH = speed * 3.6;

    if (speedKmH < 1.5) {
      return TransportMode.walking;
    } else if (speedKmH < 8.0) {
      return TransportMode.bicycle;
    } else if (speedKmH < 25.0) {
      return TransportMode.car;
    } else if (speedKmH < 30.0) {
      return TransportMode.bus;
    } else if (speedKmH < 120) {
      return TransportMode.train;
    } else {
      return TransportMode.plane;
    }
  }

  LocationData.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    speed = json['speed'];
    transport = TransportMode.fromJson(json['transport']);
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
      "speed": speed,
      "transport": transport,
      "time": time
    };
  }
}

class DailyTrackerConfig {
  static final EventEmitter emitter = EventEmitter();
  static const String newPositionEvent = "position";

  static const int _distanceErrorRange = 10; // meters

  static Timer? _gpsInterval;

  static void start() async {
    _gpsInterval?.cancel();

    _gpsInterval = Timer.periodic(Duration(seconds: await getGPSInterval()),
        (timer) async {
      if (!(await isDailyTrackedEnabled())) return;

      try {
        _checkLocationPerm();
      } catch (e) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      LocationData data = LocationData(
          position.latitude,
          position.longitude,
          position.speed,
          await getTransportMode(),
          position.timestamp.millisecondsSinceEpoch);

      _addLocation(data);
    });
  }

  static Future<void> _checkLocationPerm() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return Future.value();
  }

  static void _addLocation(LocationData data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> locations =
        prefs.getStringList(dailyTrackerLocationsPrefsName) ?? [];

    String? lastRawLocation = locations.lastOrNull;
    if (lastRawLocation != null) {
      final lastLocation = LocationData.fromJson(jsonDecode(lastRawLocation));

      double distance = Geolocator.distanceBetween(lastLocation.latitude,
          lastLocation.longitude, data.latitude, data.longitude);

      int timeDiff = data.time - lastLocation.time;

      // Avoiding inaccuracies
      if (distance < _distanceErrorRange || timeDiff == 0) return;

      // Fix speed
      if (data.speed == 0) {
        double timeInSeconds = timeDiff / 1000; // milliseconds to seconds

        data.speed = distance / timeInSeconds;
      }
    }

    locations.add(jsonEncode(data));

    emitter.emit(newPositionEvent, null, getLastEmission(locations));

    await prefs.setStringList(dailyTrackerLocationsPrefsName, locations);
  }

  static Future<bool> isDailyTrackedEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(dailyTrackerPrefsName) ?? false;
  }

  static void toggleDailyTracked(bool enable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(dailyTrackerPrefsName, enable);
  }

  static void resetDailyTracked(bool force) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(dailyTrackerLocationsPrefsName);

    if (force) {
      prefs.setBool(dailyTrackerPrefsName, false);
    }
  }

  static Future<TransportMode> getTransportMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return TransportMode.values
        .byName(prefs.getString(dailyTrackerTransportModePrefsName) ?? "auto");
  }

  static void setTransportMode(TransportMode transportMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(dailyTrackerTransportModePrefsName, transportMode.name);
  }

  static Future<int> getGPSInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(dailyTrackerGPSIntervalPrefsName) ?? 15;
  }

  static void setGPSInterval(int gpsInterval) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(dailyTrackerGPSIntervalPrefsName, gpsInterval);
    start();
  }

  static Future<List<LocationData>> getLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> locations =
        prefs.getStringList(dailyTrackerLocationsPrefsName) ?? [];

    return Future.value(locations
        .map((location) => LocationData.fromJson(jsonDecode(location)))
        .toList());
  }

  static Future<(double, double)> getResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> locations =
        prefs.getStringList(dailyTrackerLocationsPrefsName) ?? [];

    double total = 0;
    double emission = 0;

    for (int i = 1; i < locations.length; i++) {
      final location1 = LocationData.fromJson(jsonDecode(locations[i - 1]));
      final location2 = LocationData.fromJson(jsonDecode(locations[i]));

      double distanceInMeters = Geolocator.distanceBetween(location1.latitude,
          location1.longitude, location2.latitude, location2.longitude);
      double distanceInKm = distanceInMeters / 1000;

      total += distanceInMeters;
      emission += ((distanceInKm / 2) *
              location1.getTransportMode().getEmissionFactorBy(location1.speed)) +
          ((distanceInKm / 2) * location2.getTransportMode().getEmissionFactorBy(location2.speed));
    }

    return Future.value((total, emission));
  }

  static double getLastEmission(List<String> locations) {
    if (locations.length < 2) return 0;

    LocationData prevLoc = LocationData.fromJson(jsonDecode(locations[locations.length - 2]));
    LocationData currLoc = LocationData.fromJson(jsonDecode(locations[locations.length - 1]));

    double distanceInMeters = Geolocator.distanceBetween(prevLoc.latitude,
        prevLoc.longitude, currLoc.latitude, currLoc.longitude);
    double distanceInKm = distanceInMeters / 1000;

    return ((distanceInKm / 2) * currLoc.getTransportMode().getEmissionFactorBy(currLoc.speed));
  }
  
  static Future<bool> updateUserTransportEmissions(double emissions, TransportMode tm) async {
    if(tm == TransportMode.car) {
      return User.updateUserCarTransportEmissions(emissions);
    }else{
      return User.updateUserTransportEmissions(emissions);
    }
  }

  static void simulateMove(double distanceInMeters) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> locations =
        prefs.getStringList(dailyTrackerLocationsPrefsName) ?? [];

    if (locations.isEmpty) {
      print('No existing locations to simulate movement.');
      return;
    }

    String? lastRawLocation = locations.last;
    final lastLocation = LocationData.fromJson(jsonDecode(lastRawLocation!));

    double earthRadius = 6371000; // radius of Earth in meters
    double lat1 = lastLocation.latitude * (3.141592653589793 / 180); // current lat point converted to radians
    double lon1 = lastLocation.longitude * (3.141592653589793 / 180); // current lon point converted to radians
    double brng = 0; // move north
    double d = distanceInMeters;

    double lat2 = math.asin(math.sin(lat1) * math.cos(d / earthRadius) +
      math.cos(lat1) * math.sin(d / earthRadius) * math.cos(brng));
  double lon2 = lon1 + math.atan2(math.sin(brng) * math.sin(d / earthRadius) * math.cos(lat1),
      math.cos(d / earthRadius) - math.sin(lat1) * math.sin(lat2));

    double newLat = lat2 * (180 / 3.141592653589793); // convert back to degrees
    double newLon = lon2 * (180 / 3.141592653589793); // convert back to degrees

    LocationData newLocation = LocationData(
      newLat,
      newLon,
      20,
      TransportMode.car,
      DateTime.now().millisecondsSinceEpoch,
    );

    locations.add(jsonEncode(newLocation));
    await prefs.setStringList(dailyTrackerLocationsPrefsName, locations);
  }
}
