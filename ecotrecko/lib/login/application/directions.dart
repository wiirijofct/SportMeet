import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ecotrecko/dio/http_service.dart';
import 'package:ecotrecko/login/application/auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  static HttpService httpService = HttpService();
  static LatLng defaultLoc =
      const LatLng(39.3999, -8.4245); // center-ish of portugal

  static Future<DirectionsResponse> fetchNewDirections(LatLng origin,
      LatLng destination, String transportation, String? transitMode) async {
    String url = '${Authentication.getUrl()}/directions/new';

    try {
      final dio = await httpService.createDio();
      final response = await dio.post(url,
          data: jsonEncode({
            'origin': '${origin.latitude},${origin.longitude}',
            'destination': '${destination.latitude},${destination.longitude}',
            'transportation': transportation,
            'transit_mode': transitMode
          }),
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      if (response.statusCode == 200) {
        return DirectionsResponse.fromJson(response.data);
      } else {
        return DirectionsResponse.fromJson({});
      }
    } on DioException catch (e) {
      print(e.message);
      return DirectionsResponse.fromJson({});
    }
  }

  static Future<DirectionsResponse> listUserDirections(String username) async {
    String url = '${Authentication.getUrl()}/directions/list';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(
        url,
        queryParameters: {
          'username': username,
        },
      );

      if (response.statusCode == 200) {
        return DirectionsResponse.fromJson(response.data);
      } else {
        return DirectionsResponse.fromJson({});
      }
    } on DioException catch (e) {
      print(e.message);
      return DirectionsResponse.fromJson({});
    }
  }

  static Future<LatLng> fetchPlaceLatLng(String placeId) async {
    String url = '${Authentication.getUrl()}/directions/details';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(
        url,
        queryParameters: {
          'placeId': placeId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        double lat = data['geometry']['location']['lat'];
        double lng = data['geometry']['location']['lng'];

        return LatLng(lat, lng);
      } else {
        return const LatLng(0, 0);
      }
    } on DioException catch (e) {
      print(e.message);
      return const LatLng(0, 0);
    }
  }

  static Future<List<Map<String, dynamic>>> fetchSuggestions(
      LatLng location, String query) async {
    String url = '${Authentication.getUrl()}/directions/autocomplete';

    try {
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        data: jsonEncode({
          'location': '${location.latitude},${location.longitude}',
          'input': query
        }),
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> suggestions =
            response.data.map<Map<String, dynamic>>((e) {
          return {
            'place': e['structuredFormatting']['mainText'],
            'address': e['structuredFormatting']['secondaryText'],
            'placeId': e['placeId'],
          };
        }).toList();

        return suggestions;
      } else {
        return [];
      }
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }

  static Future<bool> deleteDirections(String username, String route) async {
    String url = '${Authentication.getUrl()}/directions';

    try {
      final dio = await httpService.createDio();
      final response = await dio.delete(url,
          queryParameters: {"username": username, "route": route},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<bool> deleteLocation(String locName) async {
    String url = '${Authentication.getUrl()}/locations';

    try {
      final dio = await httpService.createDio();
      final response = await dio.delete(url,
          queryParameters: {"locationName": locName},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<Map<String, Map<String, dynamic>>> fetchKnownDirections(
      String username) async {
    String url = '${Authentication.getUrl()}/directions';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url,
          queryParameters: {"username": username},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      if (response.statusCode == 200) {
        final data = (response.data as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));

        return data;
      } else {
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<Map<String, Map<String, dynamic>>> fetchKnownLocations(
      String username) async {
    String url = '${Authentication.getUrl()}/locations';

    try {
      final dio = await httpService.createDio();
      final response = await dio.get(url,
          // queryParameters: {"username": username},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      if (response.statusCode == 200) {
        final data = (response.data as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>));

        return data;
      } else {
        return {};
      }
    } on DioException catch (e) {
      print(e.message);
      return {};
    }
  }

  static Future<bool> uploadLocation(String locName, LatLng pos) async {
    String url = '${Authentication.getUrl()}/locations';

    try {
      // Routes routes = directions.routes[0];
      // Leg leg = routes.legs[0];

      final dio = await httpService.createDio();
      final response = await dio.post(url,
          data: jsonEncode({
            'name': locName,
            'latLng': '${pos.latitude},${pos.longitude}',
          }),
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<bool> shareDirections(String creatorUsername,
      String authorizedUsername, String routeName, String newRouteName) async {
    String url = '${Authentication.getUrl()}/directions/share';

    try {
      final dio = await httpService.createDio();

      final response = await dio.post(url,
          data: jsonEncode({
            'creatorUsername': creatorUsername,
            'authorizedUsername': authorizedUsername,
            'routeName': routeName,
            'newRouteName': newRouteName,
          }),
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<bool> uploadDirections(
      String routeName,
      Map<String, dynamic> directions,
      Map<Polyline, String> segments,
      bool private,
      bool compound) async {
    String url = '${Authentication.getUrl()}/directions/upload';

    try {
      final dio = await httpService.createDio();

      final segmentsList = segments.entries
          .map((entry) => {
                'summary': entry.key.polylineId.value,
                'transportation': entry.value,
                'origin':
                    '${entry.key.points.first.latitude},${entry.key.points.first.longitude}',
                'destination':
                    '${entry.key.points.last.latitude},${entry.key.points.last.longitude}',
              })
          .toList();

      String origin;
      if (compound) {
        origin =
            '${segments.keys.first.points.first.latitude},${segments.keys.first.points.first.longitude}';
      } else {
        origin = directions['origin'];
      }

      final response = await dio.post(url,
          data: jsonEncode({
            'routeName': routeName,
            'origin': origin,
            'destination': directions['destination'],
            'startAddr': directions['startAddr'],
            'endAddr': directions['endAddr'],
            'transportation': directions['transportation'],
            'visibility': private ? 'PRIVATE' : 'PUBLIC',
            'segments': segmentsList,
            'compound': compound,
          }),
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      return response.statusCode == 200;
    } on DioException catch (e) {
      print(e.message);
      return false;
    }
  }

  static Future<List<LatLng>> decodePolyline(String polyline) async {
    String url = '${Authentication.getUrl()}/directions/points';

    try {
      final dio = await httpService.createDio();

      final response = await dio.post(url,
          data: jsonEncode({'polyline': polyline}),
          options: Options(
            headers: {'Content-Type': 'application/json'},
            followRedirects: true,
          ));

      if (response.statusCode == 200) {
        return response.data.map<LatLng>((e) {
          return LatLng(e['lat'], e['lng']);
        }).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print(e.message);
      return [];
    }
  }
}

class GeocodedWaypoint {
  final String geocoderStatus;
  final bool partialMatch;
  final String placeId;
  final List<String> types;

  GeocodedWaypoint({
    required this.geocoderStatus,
    required this.partialMatch,
    required this.placeId,
    required this.types,
  });

  factory GeocodedWaypoint.fromJson(Map<String, dynamic> json) {
    return GeocodedWaypoint(
      geocoderStatus: json['geocoderStatus'],
      partialMatch: json['partialMatch'],
      placeId: json['placeId'],
      types: List<String>.from(json['types']),
    );
  }
}

class Distance {
  final int inMeters;
  final String humanReadable;

  Distance({
    required this.inMeters,
    required this.humanReadable,
  });

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      inMeters: json['inMeters'],
      humanReadable: json['humanReadable'],
    );
  }
}

class Duration {
  final int inSeconds;
  final String humanReadable;

  Duration({
    required this.inSeconds,
    required this.humanReadable,
  });

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(
      inSeconds: json['inSeconds'],
      humanReadable: json['humanReadable'],
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

//this collides with the flutter_polyline_points package so I had to change it
class FlutterPolyline {
  final String points;

  FlutterPolyline({
    required this.points,
  });

  factory FlutterPolyline.fromJson(Map<String, dynamic> json) {
    return FlutterPolyline(
      points: json['points'],
    );
  }
}

class Step {
  final String htmlInstructions;
  final Distance distance;
  final Duration duration;
  final Location startLocation;
  final Location endLocation;
  final FlutterPolyline polyline;
  final String travelMode;
  final String? maneuver;

  Step({
    required this.htmlInstructions,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.polyline,
    required this.travelMode,
    this.maneuver,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      htmlInstructions: json['htmlInstructions'],
      distance: Distance.fromJson(json['distance']),
      duration: Duration.fromJson(json['duration']),
      startLocation: Location.fromJson(json['startLocation']),
      endLocation: Location.fromJson(json['endLocation']),
      polyline: FlutterPolyline.fromJson(json['polyline']),
      travelMode: json['travelMode'],
      maneuver: json['maneuver'],
    );
  }
}

class Leg {
  final List<Step> steps;
  final Distance distance;
  final Duration duration;
  final Location startLocation;
  final Location endLocation;
  final String startAddress;
  final String endAddress;

  Leg({
    required this.steps,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
    required this.startAddress,
    required this.endAddress,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    var stepsJson = json['steps'] as List;
    List<Step> stepList = stepsJson.map((i) => Step.fromJson(i)).toList();

    return Leg(
      steps: stepList,
      distance: Distance.fromJson(json['distance']),
      duration: Duration.fromJson(json['duration']),
      startLocation: Location.fromJson(json['startLocation']),
      endLocation: Location.fromJson(json['endLocation']),
      startAddress: json['startAddress'],
      endAddress: json['endAddress'],
    );
  }
}

class Routes {
  final String summary;
  final List<Leg> legs;
  final String overviewPolyline;
  final String copyrights;

  Routes({
    required this.summary,
    required this.legs,
    required this.overviewPolyline,
    required this.copyrights,
  });

  factory Routes.fromJson(Map<String, dynamic> json) {
    var legsJson = json['legs'] as List;
    List<Leg> legList = legsJson.map((i) => Leg.fromJson(i)).toList();

    return Routes(
      summary: json['summary'],
      legs: legList,
      overviewPolyline: json['overviewPolyline']['points'],
      copyrights: json['copyrights'],
    );
  }
}

class DirectionsResponse {
  final List<GeocodedWaypoint> geocodedWaypoints;
  final List<Routes> routes;

  DirectionsResponse({
    required this.geocodedWaypoints,
    required this.routes,
  });

  factory DirectionsResponse.fromJson(Map<String, dynamic> json) {
    var geocodedWaypointsJson = json['geocodedWaypoints'] as List;
    List<GeocodedWaypoint> geocodedWaypointsList =
        geocodedWaypointsJson.map((i) => GeocodedWaypoint.fromJson(i)).toList();

    var routesJson = json['routes'] as List;
    List<Routes> routesList =
        routesJson.map((i) => Routes.fromJson(i)).toList();

    return DirectionsResponse(
      geocodedWaypoints: geocodedWaypointsList,
      routes: routesList,
    );
  }
}
