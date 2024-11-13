// ignore_for_file: constant_identifier_names, deprecated_member_use, use_build_context_synchronously, avoid_print

import 'dart:math';

import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/login/themes/dark_theme.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:ecotrecko/map_template/darkTemplate.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/directions.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

const String WALKING = "walking";
const String DRIVING = "driving";
const String TRANSIT = "transit";
const String BICYCLING = "bicycling";

const String TOLLS = "tolls";
const String HIGHWAYS = "highways";
const String FERRIES = "ferries";
const String INDOOR = "indoor";

const String BUS = "bus";
const String SUBWAY = "subway";
const String TRAIN = "train";
const String TRAM = "tram";
const String RAIL = "rail";

const String LESS_WALKING = "less_walking";
const String FEWER_TRANSFERS = "fewer_transfers";

void main() => runApp(const MapPage());

class MapPage extends StatefulWidget {
  final MapEntry<String, Map<String, dynamic>>? sharedRoute;

  const MapPage({super.key, this.sharedRoute});

  @override
  // ignore: no_logic_in_create_state
  State<MapPage> createState() => _MapPageState(sharedRoute);
}

class _MapPageState extends State<MapPage> {
  MapEntry<String, Map<String, dynamic>>? sharedRoute;
  late GoogleMapController _mapController;
  late TextEditingController _directionsController;

  _MapPageState(this.sharedRoute);

  static const double _initialZoom = 15.0;
  double _zoom = _initialZoom;

  bool compoundRoute = false;
  bool privateRoute = true;
  bool _newFetch = true;

  LatLng? _cameraPos;
  LatLng? _initialPos;
  LatLng? _origin;
  LatLng? _newOrigin;
  LatLng? _destination;
  Marker? _originMarker;
  Marker? _destinationMarker;
  String? _selectedRoute;
  String _transportation = WALKING;
  String _oldTransportation = WALKING;
  String? transitMode;
  MaterialColor _color = Colors.green;

  Map<String, dynamic> _directions = {};

  List<String> _polylineIDs = [];
  Map<int, Distance> _distances = {};
  Map<int, Duration> _durations = {};
  Map<int, String> _emissions = {};

  Map<String, Color> _polylineColors = {};
  Map<String, String> _polylineInfo = {};
  Map<String, String> _placeIds = {};
  Set<Polyline> _fetchedPolylineSet = {};
  Set<Polyline> _polylineSet = {};
  Map<Polyline, String> _routeSegments = {};

  final Map<String, MaterialColor> _transportationColor = {
    WALKING: Colors.green,
    TRANSIT: Colors.blue,
    BICYCLING: Colors.lightGreen,
    DRIVING: Colors.red
  };

  final Map<String, IoniconsData> _transportationIcon = {
    WALKING: Ionicons.walk_outline,
    TRANSIT: Ionicons.bus_outline,
    BICYCLING: Ionicons.bicycle_outline,
    DRIVING: Ionicons.car_outline,
  };

  late Future<Map<String, Map<String, dynamic>>> _knownDirections;
  late Future<Map<String, Map<String, dynamic>>> _knownLocations;

  Map<String, dynamic> userInfo = User.info;
  String username = User.info['username'] ?? "";

  BitmapDescriptor? markerIcon;
  late Future<BitmapDescriptor> _markerIcon;

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
    _getKnownDirections();
    _directionsController = TextEditingController();

    // if (sharedRoute != null) {
    //   _showRouteOnMap(sharedRoute!);
    // }
  }

  @override
  void dispose() {
    _directionsController.dispose();
    _directionsController.dispose();
    super.dispose();
  }

  void _getKnownDirections() {
    _knownLocations = Directions.fetchKnownLocations(username);
    _knownDirections = Directions.fetchKnownDirections(username);
  }

  Future<void> _getInitialLocation() async {
    _markerIcon = BitmapDescriptor.asset(
      const ImageConfiguration(),
      'lib/images/Gecko.png',
      width: 50,
      height: 50,
    );

    LatLng defaultLoc = Directions.defaultLoc;

    Geolocator.checkPermission().then((value) async {
      if (value == LocationPermission.deniedForever) {
        setState(() {
          _initialPos = defaultLoc;
          _cameraPos = defaultLoc;
          _zoom = 7.0;
        });
        return;
      } else if (value == LocationPermission.denied) {
        if (await Geolocator.requestPermission() == LocationPermission.denied) {
          setState(() {
            _initialPos = defaultLoc;
            _cameraPos = defaultLoc;
            _zoom = 7.0;
          });
          return;
        }
      }
    });

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng currentPos = LatLng(position.latitude, position.longitude);

    setState(() {
      _initialPos = currentPos;
      _cameraPos = currentPos;
    });
  }

  void _getDirections() async {
    if (_originMarker == null) {
      setState(() {
        _origin = _initialPos!;
        _originMarker = _makeMarker(const MarkerId("Origin"),
            const InfoWindow(title: "Origin"), _initialPos!, markerIcon);
      });
    }

    _drawRoute(
        await Directions.fetchNewDirections(
            _origin!, _destination!, _transportation, transitMode),
        true);
  }

  void _drawCompRoute(DirectionsResponse directions, String segSummary,
      MaterialColor segColor) async {
    Map<dynamic, List<LatLng>> polylineMap = {};

    for (int i = 0; i < directions.routes.length; i++) {
      dynamic summary = directions.routes[i].summary;
      if (summary.isEmpty) summary = i.toString();

      if (summary == segSummary) {
        String polyline = directions.routes[i].overviewPolyline;

        polylineMap[summary] = await Directions.decodePolyline(polyline);

        _durations[i] = directions.routes[i].legs[0].duration;
        _distances[i] = directions.routes[i].legs[0].distance;
        if (_transportation != WALKING && _transportation != BICYCLING) {
          _emissions[i] = "${_calcEmissions(_distances[i]!.inMeters)} kg CO2";
        } else {
          _emissions[i] = "";
        }
      }
    }

    setState(() {
      _fetchedPolylineSet = _toPolylineSets(polylineMap, segColor);

      _polylineSet.addAll(_fetchedPolylineSet);

      if (_originMarker == null) {}
    });
  }

  void _drawRoute(DirectionsResponse directions, bool correctOrigin) async {
    Map<dynamic, List<LatLng>> polylineMap = {};

    for (int i = 0; i < directions.routes.length; i++) {
      dynamic summary = directions.routes[i].summary;
      if (summary.isEmpty) summary = i.toString();

      String polyline = directions.routes[i].overviewPolyline;

      polylineMap[summary] = await Directions.decodePolyline(polyline);

      _durations[i] = directions.routes[i].legs[0].duration;
      _distances[i] = directions.routes[i].legs[0].distance;
      if (_transportation != WALKING && _transportation != BICYCLING) {
        _emissions[i] = "${_calcEmissions(_distances[i]!.inMeters)} kg CO2";
      } else {
        _emissions[i] = "";
      }
    }

    // this is just to correct the markers' placement relative to roads and such
    var origin = directions.routes[0].legs[0].startLocation;
    var destination = directions.routes[0].legs[0].endLocation;

    _directions = {
      'startAddr': directions.routes[0].legs[0].startAddress,
      'endAddr': directions.routes[0].legs[0].endAddress,
      'transportation': _transportation,
      'origin': "${origin.lat},${origin.lng}",
      'destination': "${destination.lat},${destination.lng}",
    };

    setState(() {
      // _directions = directions;
      // in case no specific route was selected from the dropdown

      _destination = LatLng(destination.lat, destination.lng);
      _selectedRoute = null;
      _fetchedPolylineSet = _toPolylineSets(polylineMap, _color);

      if (!compoundRoute) {
        _polylineSet = {};
      }

      _polylineSet.addAll(_fetchedPolylineSet);

      if (compoundRoute) {
        _polylineSet.addAll(_routeSegments.keys.toSet());
        _newFetch = true;
      }

      if (correctOrigin) {
        _origin = LatLng(origin.lat, origin.lng);
        _originMarker = _originMarker == null
            ? _makeMarker(const MarkerId('Origin'),
                const InfoWindow(title: 'Origin'), _origin!, markerIcon)
            : _moveMarkerTo(_originMarker!, _origin!);
      }
      _destinationMarker = _destinationMarker == null
          ? _makeMarker(const MarkerId('Destination'),
              const InfoWindow(title: 'Destination'), _destination!, null)
          : _moveMarkerTo(_destinationMarker!, _destination!);
    });
  }

  void _recenterCamera() {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPos!,
          zoom: 15.0,
        ),
      ),
    );
  }

  void _moveCameraToLatLng(LatLng pos, double zoom) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos,
          zoom: zoom,
        ),
      ),
    );

    setState(() {
      _cameraPos = pos;
    });
  }

  void _placeCompMarker(LatLng pos, String? place, String? placeId) async {
    String dest = "Destination";
    String ori = "Origin";

    setState(() {
      if (_origin == null) {
        _origin = pos;
        _newOrigin = pos;
        _originMarker = _makeMarker(MarkerId(placeId ?? ori),
            InfoWindow(title: place ?? ori), pos, markerIcon);
      } else {
        _newOrigin ??= _destination;
        _destination = pos;
        _destinationMarker = _makeMarker(MarkerId(placeId ?? dest),
            InfoWindow(title: place ?? dest), pos, null);
      }
    });

    if (_newOrigin != null && _destination != null) {
      bool correctOrigin = _origin == _newOrigin;
      _drawRoute(
          await Directions.fetchNewDirections(
              _newOrigin!, _destination!, _transportation, transitMode),
          correctOrigin);
      _newOrigin = null;
    }
  }

  void _placeMarker(LatLng pos, String? place, String? placeId) {
    String dest = "Destination";
    String ori = "Origin";

    setState(() {
      if (_destination == null || _origin != null) {
        // _moveCameraToLatLng(pos, _zoom);
        _destination = pos;
        _destinationMarker = _makeMarker(MarkerId(placeId ?? dest),
            InfoWindow(title: place ?? dest), pos, null);
      } else {
        _origin = pos;
        _originMarker = _makeMarker(MarkerId(placeId ?? ori),
            InfoWindow(title: place ?? ori), pos, markerIcon);
      }
    });

    if (_origin != null) _getDirections();
  }

  void _clearDirections() {
    setState(() {
      _getCurrentLocation();
      _newFetch = true;

      _origin = null;
      _newOrigin = null;
      _destination = null;
      _originMarker = null;
      _destinationMarker = null;
      _selectedRoute = null;

      transitMode = null;
      _directions = {};

      _polylineIDs = [];
      _distances = {};
      _durations = {};
      _emissions = {};
      _polylineColors = {};
      _polylineInfo = {};
      _placeIds = {};
      _fetchedPolylineSet = {};
      _polylineSet = {};
      _routeSegments = {};
    });
  }

  void _showAllRoutes() {
    setState(() {
      _polylineSet = {};
      _polylineSet.addAll(_fetchedPolylineSet);
      if (compoundRoute) _polylineSet.addAll(_routeSegments.keys.toSet());
      _selectedRoute = null;
    });
  }

  String _calcEmissions(int distanceMeters) {
    double distKm = distanceMeters / 1000;
    double ltrsPer100km = 6.5;
    double ratio = ltrsPer100km / 100;

    double ltrs = distKm * ratio;

    // 2.3kg of CO2 per liter of gasoline,
    // 2.7kg if it's diesel
    // according to some article I found
    double emissions = ltrs * 2.7;

    return emissions.toStringAsFixed(2);
  }

  Marker _moveMarkerTo(Marker marker, LatLng pos) {
    return _makeMarker(marker.markerId, marker.infoWindow, pos, marker.icon);
  }

  Marker _makeMarker(
      MarkerId id, InfoWindow infoW, LatLng pos, BitmapDescriptor? icon) {
    return Marker(
      markerId: id,
      infoWindow: infoW,
      icon: icon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      position: pos,
    );
  }

  // futures

  Future<void> _moveCameraToPlace(String place, String placeId) async {
    LatLng pos = await Directions.fetchPlaceLatLng(placeId);

    _moveCameraToLatLng(pos, _zoom);

    compoundRoute
        ? _placeCompMarker(pos, place, placeId)
        : _placeMarker(pos, place, placeId);
  }

  Future<List<String>> _fetchSuggestions(String query) async {
    List<Map<String, dynamic>> suggestionsRes =
        await Directions.fetchSuggestions(_cameraPos!, query);

    List<String> placeSuggestions = [];
    _placeIds = {};
    for (var suggestion in suggestionsRes) {
      String place = suggestion['place'];
      String address = suggestion['address'];
      String placeAddress = "$place - $address";
      placeSuggestions.add(placeAddress);
      _placeIds[placeAddress] = suggestion['placeId'];
    }
    return placeSuggestions;
  }

  Future<void> _getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng currentPos = LatLng(position.latitude, position.longitude);

    setState(() {
      _initialPos = currentPos;
      _cameraPos = currentPos;
    });
  }

  Set<Polyline> _toPolylineSets(
      Map<dynamic, List<LatLng>> polylineMap, MaterialColor col) {
    Set<Polyline> polySet = {};

    polylineMap.forEach((key, value) {
      polySet.add(Polyline(
        polylineId: PolylineId(key),
        visible: true,
        points: value,
        color: col,
        width: 4,
      ));
    });

    return polySet;
  }

  // widgets

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.42;
    final panelHeightClosed = MediaQuery.of(context).size.height * 0.13;

    return FutureBuilder<BitmapDescriptor>(
      future: _markerIcon,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          markerIcon = snapshot.data;

          return MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
            ),
            home: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.background,
                      Theme.of(context).colorScheme.primary,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Ionicons.arrow_back_circle_outline,
                                color: Theme.of(context).colorScheme.onTertiary,
                                size: 30,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        _map(),
                        SlidingUpPanel(
                          maxHeight: panelHeightOpen,
                          minHeight: panelHeightClosed,
                          parallaxEnabled: true,
                          parallaxOffset: .5,
                          panel: Container(
                            color: Theme.of(context).colorScheme.primary,
                            child: _menu(),
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  double _calcDistance(LatLng origin, LatLng destination) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((destination.latitude - origin.latitude) * p) / 2 +
        c(origin.latitude * p) *
            c(destination.latitude * p) *
            (1 - c((destination.longitude - origin.longitude) * p)) /
            2;

    return 12742 * asin(sqrt(a));
  }

  double _calcZoom(LatLng origin, LatLng destination) {
    double distance = _calcDistance(origin, destination);
    if (distance < 2) {
      return 15;
    } else if (distance < 5) {
      return 14;
    } else if (distance < 10) {
      return 13;
    } else if (distance < 20) {
      return 12;
    } else if (distance < 50) {
      return 11;
    } else if (distance < 100) {
      return 10;
    } else if (distance < 200) {
      return 9;
    } else if (distance < 500) {
      return 8;
    } else if (distance < 1000) {
      return 7;
    } else {
      return 5;
    }
  }

  Expanded _map() {
    return Expanded(
      flex: 3,
      child: _initialPos == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(),
              child: GoogleMap(
                style: Provider.of<ThemeManager>(context).themeData == darkTheme
                    ? darkMapStyle
                    : null,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;

                  if (sharedRoute != null) {
                    _showRouteOnMap(sharedRoute!);
                  }
                },
                onCameraMove: (CameraPosition position) {
                  _cameraPos = position.target;
                },
                polylines: _polylineSet,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _initialPos!,
                  zoom: _zoom,
                ),
                markers: {
                  if (_originMarker != null) _originMarker!,
                  if (_destinationMarker != null) _destinationMarker!
                },
                onTap: (LatLng pos) {
                  if (!compoundRoute) {
                    _placeMarker(pos, null, null);
                  } else {
                    _placeCompMarker(pos, null, null);
                  }
                },
              ),
            ),
    );
  }

  Widget _menu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  buildDragIcon(),
                  const SizedBox(height: 10),
                  // buildOptionsText(),
                  // const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_destinationMarker != null)
                                  _getDirectionsIcon(),
                                _clearDirectionsIcon(),
                                _recenterIcon(),
                                _compoundToggleIcon(),
                              ],
                            ),
                            _searchBar(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _transportationButtons(),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: _loadRouteButton(),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: 110,
                                      child: _showLocationsIcon(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            if (_directions.isNotEmpty)
                              Column(
                                children: [
                                  _routeDropdown(),
                                  const SizedBox(height: 10),
                                  if (_selectedRoute != null &&
                                      _polylineSet.length > 1)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 16),
                                        _showAllButton(),
                                      ],
                                    ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_destinationMarker != null)
                                  Row(
                                    children: [
                                      _saveLocationButton(),
                                      const SizedBox(width: 5),
                                      if (_directions.isNotEmpty)
                                        _saveRouteButton(),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  DropdownButton<String> _routeDropdown() {
    if (_fetchedPolylineSet.isEmpty) {
      return DropdownButton<String>(
        hint: const Text("Select a route"),
        style: const TextStyle(fontSize: 10),
        items: const [],
        onChanged: (String? value) {},
      );
    }

    for (var polyline in _fetchedPolylineSet) {
      _polylineColors[polyline.polylineId.value] = polyline.color;
    }

    _polylineIDs = _fetchedPolylineSet.map((Polyline route) {
      return route.polylineId.value;
    }).toList();

    for (int i = 0; i < _polylineIDs.length; i++) {
      _polylineInfo[_polylineIDs[i]] =
          "${_durations[i]!.humanReadable}, ${_distances[i]!.humanReadable}";

      if (_transportation != WALKING && _transportation != BICYCLING) {
        _polylineInfo[_polylineIDs[i]] =
            ("${_polylineInfo[_polylineIDs[i]]}, ${_emissions[i]}");
      }

      _polylineInfo[_polylineIDs[i]] =
          ("${_polylineInfo[_polylineIDs[i]]}\n${_polylineIDs[i]}");
    }

    if (_fetchedPolylineSet.length == 1) {
      _selectedRoute = _polylineIDs[0];
      if (compoundRoute) {
        _routeSegments.putIfAbsent(
            _fetchedPolylineSet.elementAt(0), () => _transportation);
      }
    }

    return DropdownButton<String>(
      hint: Text(
          _selectedRoute == null //&& _polylineInfo != null
              ? "Select a route"
              : _polylineInfo[_selectedRoute]!,
          style: TextStyle(
              color: _selectedRoute == null
                  ? Theme.of(context).colorScheme.onTertiary.withOpacity(0.6)
                  : Theme.of(context).colorScheme.onTertiary,
              fontFamily: "FredokaRegular",
              fontSize: 13)),
      items: _polylineIDs.map((String route) {
        return DropdownMenuItem<String>(
          value: route,
          child: Text(_polylineInfo[route]!,
              style: TextStyle(
                  color: _polylineColors[route],
                  fontFamily: "FredokaRegular",
                  fontSize: 13)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRoute = newValue;
          _polylineSet = _fetchedPolylineSet.map((Polyline route) {
            if (route.polylineId.value == newValue) {
              if (compoundRoute) {
                if (_newFetch) {
                  _routeSegments[route] = _transportation;
                } else {
                  _routeSegments[route] = _oldTransportation;
                }
              }
              return Polyline(
                polylineId: route.polylineId,
                visible: true,
                points: route.points,
                color: _polylineColors[route.polylineId.value] ?? _color,
                width: route.width,
              );
            } else {
              if (compoundRoute) {
                _routeSegments.remove(route);
              }
              return Polyline(
                polylineId: route.polylineId,
                visible: false,
                points: route.points,
                color: route.color,
                width: route.width,
              );
            }
          }).toSet();
          if (compoundRoute) _polylineSet.addAll(_routeSegments.keys.toSet());
        });
      },
    );
  }

  Autocomplete<String> _searchBar() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '' || textEditingValue.text.length < 3) {
          return const Iterable<String>.empty();
        }
        return _fetchSuggestions(textEditingValue.text);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              color: Colors.white,
              width: 250.0,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: (String selection) {
        var place = selection.split(" - ")[0];
        var placeId = _placeIds[selection];
        _moveCameraToPlace(place, placeId!);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8.0),
            Container(
              width: min(MediaQuery.of(context).size.width * 0.8, 300.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12.0),
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                        hintText: 'Search for a place...',
                        prefixIcon: Transform.translate(
                          offset: const Offset(-10, 0),
                          child: IconButton(
                            icon: const Icon(Ionicons.search_outline),
                            onPressed: () {
                              textEditingController.clear();
                            },
                          ),
                        ),
                        suffixIcon: Transform.translate(
                          offset: const Offset(10, 0),
                          child: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              textEditingController.clear();
                            },
                          ),
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 14.0, fontFamily: "FredokaRegular"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateRoute() async {
    if (_destinationMarker != null && _originMarker != null && !compoundRoute) {
      _drawRoute(
          await Directions.fetchNewDirections(
              _origin!, _destination!, _transportation, transitMode),
          true);
    }
  }

  Column _transportationButton(String transportation) {
    MaterialColor color = _transportationColor[transportation]!;
    IoniconsData icondt = _transportationIcon[transportation]!;
    return Column(
      children: [
        IconButton(
            isSelected: _transportation == transportation,
            selectedIcon: CircleAvatar(
              backgroundColor: color,
              child: Icon(
                icondt,
                color: Colors.black,
                size: 30,
              ),
            ),
            onPressed: () {
              if (compoundRoute &&
                  _selectedRoute == null &&
                  _fetchedPolylineSet.isNotEmpty &&
                  _newFetch) {
                _routeSegments.putIfAbsent(
                    _fetchedPolylineSet.elementAt(0), () => _transportation);
                _polylineSet = _routeSegments.keys.toSet();
              }
              if (_newFetch) {
                _newFetch = false;
                _oldTransportation = _transportation;
              }
              setState(() {
                _transportation = transportation;
                _color = color;
                _updateRoute();
              });
            },
            icon: CircleAvatar(
              backgroundColor: color,
              child: Icon(
                icondt,
                color: Colors.white,
                size: 30,
              ),
            )),
        Text(capitalize(transportation),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontFamily: 'FredokaRegular',
            ))
      ],
    );
  }

  Row _transportationButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _transportationButton(WALKING),
        _transportationButton(TRANSIT),
        _transportationButton(DRIVING),
        _transportationButton(BICYCLING),
      ],
    );
  }

  Future _showRouteOnMap(MapEntry<String, Map<String, dynamic>> entry) async {
    String origin = entry.value['origin'];
    String destination = entry.value['destination'];

    double oLat = double.parse(origin.split(",")[0]);
    double oLon = double.parse(origin.split(",")[1]);

    double dLat = double.parse(destination.split(",")[0]);
    double dLon = double.parse(destination.split(",")[1]);

    LatLng originLl = LatLng(oLat, oLon);
    LatLng destinationLl = LatLng(dLat, dLon);

    _clearDirections();

    markerIcon = await _markerIcon;

    _origin = originLl;
    _originMarker = _makeMarker(const MarkerId("Origin"),
        const InfoWindow(title: "Origin"), originLl, markerIcon);
    _destination = destinationLl;
    _destinationMarker = _makeMarker(const MarkerId("Destination"),
        const InfoWindow(title: "Destination"), destinationLl, null);

    LatLng midpoint = LatLng((_origin!.latitude + _destination!.latitude) / 2,
        (_origin!.longitude + _destination!.longitude) / 2);

    _moveCameraToLatLng(midpoint, _calcZoom(_origin!, _destination!));

    if (entry.value['compound']) {
      compoundRoute = true;

      entry.value['segments'].forEach((segment) async {
        String value = segment['value'];
        List<String> splits = value.split(", ");

        String summary = splits[0].split("=")[1];
        String segTransportation = splits[1].split("=")[1];
        String origin = splits[2].split("=")[1];
        String destination = splits[3].split("=")[1];

        double oLat = double.parse(origin.split(",")[0]);
        double oLon = double.parse(origin.split(",")[1]);

        double dLat = double.parse(destination.split(",")[0]);
        double dLon = double.parse(destination.split(",")[1]);

        LatLng originLl = LatLng(oLat, oLon);
        LatLng destinationLl = LatLng(dLat, dLon);

        MaterialColor segColor = _transportationColor[segTransportation]!;

        _drawCompRoute(
            await Directions.fetchNewDirections(
                originLl, destinationLl, segTransportation, transitMode),
            summary,
            segColor);
      });
    } else {
      compoundRoute = false;
      String preferredTransportation = entry.value['transportation'];

      _drawRoute(
          await Directions.fetchNewDirections(
              originLl, destinationLl, preferredTransportation, transitMode),
          true);
    }
  }

  Row _showRouteButton(MapEntry<String, Map<String, dynamic>> entry) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _showRouteOnMap(entry);
          Navigator.of(context).pop();
        },
        child: const Icon(
          Ionicons.map_outline,
          size: 20,
        ),
      ),
    ]);
  }

  _deleteLocationButtonPressed(String entryKey) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Delete location',
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold),
            ),
            content: Text('Are you sure you want to delete this location?',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary))),
              TextButton(
                onPressed: () async {
                  if (await Directions.deleteLocation(entryKey)) {
                    _getKnownDirections();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Success',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontWeight: FontWeight.bold),
                          ),
                          content: const Text('Location deleted successfully'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text('OK',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary)),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                          content: Text('Failed to delect location!',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Ok',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Yes',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary)),
              ),
            ],
          );
        });
  }

  _deleteDirectionButtonPressed(String entryKey) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Delete directions',
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold),
            ),
            content: Text('Are you sure you want to delete these directions?',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onTertiary)),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary))),
              TextButton(
                onPressed: () async {
                  if (await Directions.deleteDirections(username, entryKey)) {
                    _getKnownDirections();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Success',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontWeight: FontWeight.bold),
                          ),
                          content:
                              const Text('Directions deleted successfully'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text('OK',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary)),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                          content: Text('Failed to delete directions',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiary)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Yes',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary)),
              ),
            ],
          );
        });
  }

  Row _deleteDirectionButton(String entryKey, bool directions) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          if (directions) {
            _deleteDirectionButtonPressed(entryKey);
          } else {
            _deleteLocationButtonPressed(entryKey);
          }
        },
        child: const Icon(
          Ionicons.trash_outline,
          size: 20,
        ),
      ),
    ]);
  }

  List<ListTile> _buildList(
      Map<String, Map<String, dynamic>> routeOrLocMap, bool directions) {
    return routeOrLocMap.entries
        .map((entry) => ListTile(
            title:
                Text(entry.key, style: Theme.of(context).textTheme.labelMedium),
            subtitle: directions
                ? Text(
                    "\t\t${entry.value['startAddr']}\n\t\t${entry.value['endAddr']}",
                    style: Theme.of(context).textTheme.bodySmall)
                : Text("\t\t${entry.value['address']}",
                    style: Theme.of(context).textTheme.bodySmall),
            trailing: directions
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        _deleteDirectionButton(entry.key, directions),
                        _showRouteButton(entry),
                      ])
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        _deleteDirectionButton(entry.key, directions),
                        _showLocationButton(entry),
                      ])))
        .toList();
  }

  Row _showLocationButton(MapEntry<String, Map<String, dynamic>> entry) {
    String latLng = entry.value['latLng'];
    double lat = double.parse(latLng.split(",")[0]);
    double lng = double.parse(latLng.split(",")[1]);
    LatLng pos = LatLng(lat, lng);

    String address = entry.value['address'];

    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          // _clearDirections();
          _moveCameraToLatLng(pos, _zoom);
          compoundRoute
              ? _placeCompMarker(
                  pos, address.split(",")[0], address.split(",")[1])
              : _placeMarker(pos, address.split(",")[0], address.split(",")[1]);
          Navigator.of(context).pop();
        },
        child: const Icon(
          Ionicons.map_outline,
          size: 20,
        ),
      ),
    ]);
  }

  Future<Future> _loadRouteButtonPressed() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Load Directions',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeight.bold),
          ),
          content: FutureBuilder<Map<String, Map<String, dynamic>>>(
            future: _knownDirections,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var directions = snapshot.data!;
                return SingleChildScrollView(
                    child: Column(
                  children: _buildList(directions, true),
                ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Close',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary)),
            ),
          ],
        );
      },
    );
  }

  Future<Future> _showKnownLocations() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Known Locations',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeight.bold),
          ),
          content: FutureBuilder<Map<String, Map<String, dynamic>>>(
            future: _knownLocations,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var locations = snapshot.data!;
                return SingleChildScrollView(
                    child: Column(
                  children: _buildList(locations, false),
                ));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Close',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary)),
            ),
          ],
        );
      },
    );
  }

  Future<Future> _saveLocationButtonPressed() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Upload location',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 100,
            height: 40,
            child: TextField(
                style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onTertiary),
                controller: _directionsController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  labelText: 'eg: Home, Work...',
                  counterStyle: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onTertiary),
                  helperStyle: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onTertiary),
                  floatingLabelStyle: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onTertiary),
                  prefixStyle: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onTertiary),
                  suffixStyle: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onTertiary),
                  labelStyle: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onTertiary),
                )),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await Directions.uploadLocation(
                    _directionsController.text, _destinationMarker!.position)) {
                  Navigator.of(context).pop(true);
                  _getKnownDirections();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Success',
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text('Location uploaded successfully',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onTertiary)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary)),
                          ),
                        ],
                      );
                    },
                  );
                  _directionsController.clear();
                } else {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onTertiary)),
                        content: Text('Failed to upload location',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onTertiary)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onTertiary),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary)),
            ),
          ],
        );
      },
    );
  }

  Future<Future> _saveRouteButtonPressed() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Upload directions',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeight.bold),
          ),
          content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onTertiary),
                    controller: _directionsController,
                    decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      border: const OutlineInputBorder(),
                      labelText: 'eg: Home, Work...',
                      labelStyle: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onTertiary),
                    )),
                StatefulBuilder(builder: (context, setState) {
                  return Column(children: [
                    Row(children: [
                      Text('Private ',
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onTertiary)),
                      Checkbox(
                          activeColor: Theme.of(context).colorScheme.onTertiary,
                          value: privateRoute,
                          onChanged: (bool? val) {
                            setState(() {
                              privateRoute = !privateRoute;
                            });
                          }),
                    ]),
                  ]);
                })
              ]),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  if (compoundRoute &&
                      _selectedRoute == null &&
                      _fetchedPolylineSet.isNotEmpty) {
                    var poly = _fetchedPolylineSet.elementAt(0);
                    _routeSegments.putIfAbsent(poly, () => _transportation);
                    _polylineSet = _routeSegments.keys.toSet();
                    _selectedRoute = poly.polylineId.value;
                  }
                });
                if (await Directions.uploadDirections(
                    _directionsController.text,
                    _directions,
                    _routeSegments,
                    privateRoute,
                    compoundRoute)) {
                  Navigator.of(context).pop(true);
                  _getKnownDirections();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Success',
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text('Directions uploaded successfully',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onTertiary)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // setState(() {
                              //   _getKnownDirections();
                              // });
                            },
                            child: Text('OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary)),
                          ),
                        ],
                      );
                    },
                  );
                  _directionsController.clear();
                } else {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onTertiary)),
                        content: Text('Failed to upload directions',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onTertiary)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text('OK',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary)),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary)),
            ),
          ],
        );
      },
    );
  }

  ElevatedButton _loadRouteButton() {
    return ElevatedButton(
      onPressed: () {
        _loadRouteButtonPressed();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Routes',
        style: TextStyle(
            fontSize: 13, color: Colors.black, fontFamily: 'FredokaRegular'),
      ),
    );
  }

  ElevatedButton _saveLocationButton() {
    return ElevatedButton(
      onPressed: () {
        if (_destinationMarker != null) {
          _saveLocationButtonPressed();
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Save Location',
        style: TextStyle(fontSize: 16, fontFamily: 'FredokaRegular'),
      ),
    );
  }

  ElevatedButton _saveRouteButton() {
    return ElevatedButton(
      onPressed: () {
        _saveRouteButtonPressed();
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Save Route',
        style: TextStyle(fontSize: 16, fontFamily: 'FredokaRegular'),
      ),
    );
  }

  ElevatedButton _showAllButton() {
    return ElevatedButton(
      onPressed: _showAllRoutes,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Show All Routes',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  IconButton _getDirectionsIcon() {
    return IconButton(
        onPressed: () {
          setState(() {
            _getDirections();
          });
        },
        icon: Icon(Ionicons.navigate_outline,
            color: Theme.of(context).colorScheme.onTertiary));
  }

  IconButton _clearDirectionsIcon() {
    return IconButton(
        onPressed: () {
          setState(() {
            _clearDirections();
          });
        },
        icon: Icon(Ionicons.close_outline,
            color: Theme.of(context).colorScheme.onTertiary));
  }

  IconButton _recenterIcon() {
    return IconButton(
        onPressed: () {
          setState(() {
            _recenterCamera();
          });
        },
        icon: Icon(Ionicons.locate_outline,
            color: Theme.of(context).colorScheme.onTertiary));
  }

  IconButton _compoundToggleIcon() {
    return IconButton(
      isSelected: compoundRoute,
      onPressed: () {
        setState(() {
          compoundRoute = !compoundRoute;
        });
      },
      icon: Icon(Icons.add_location_alt_outlined,
          color: compoundRoute
              ? Colors.blue
              : Theme.of(context).colorScheme.onTertiary),
    );
  }

  _showLocationsIcon() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _showKnownLocations();
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Locations',
        style: TextStyle(
            fontSize: 13, fontFamily: "FredokaRegular", color: Colors.black),
      ),
    );
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  buildDragIcon() => Center(
        child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  buildOptionsText() {
    return Text(
      "Options",
      style: TextStyle(
        color: Theme.of(context).colorScheme.onTertiary,
        fontSize: 25,
        fontFamily: "FredokaRegular",
      ),
    );
  }
}
