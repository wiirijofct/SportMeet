import 'dart:async';

import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:ecotrecko/login/themes/dark_theme.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:ecotrecko/map_template/darkTemplate.dart';
import 'package:ecotrecko/map_template/lightTemplate.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/daily_tracker.dart';
import 'package:ecotrecko/login/presentation/DailyTracker/emission_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

void main() => runApp(const DailyTracker());

class DailyTracker extends StatefulWidget {
  const DailyTracker({super.key});

  @override
  State<DailyTracker> createState() => _DailyTrackerState();
}

class _DailyTrackerState extends State<DailyTracker>
    with SingleTickerProviderStateMixin {
  static const List<Tab> tabs = [
    Tab(
      text: 'Power',
    ),
    Tab(text: 'Statistics'),
    Tab(text: 'Map')
  ];
  static const List<(int, String)> gpsIntervalItems = [
    (3, "3 seconds"),
    (10, "10 seconds"),
    (30, "30 seconds"),
    (60, "1 minute"),
    (60 * 3, "5 minutes"),
    (60 * 15, "15 minutes"),
    (60 * 30, "30 minutes"),
    (60 * 60, "1 hour")
  ];

  Timer? _timer;

  late TabController _tabController;

  bool isDailyTrackerEnabled = false;
  TransportMode transportMode = TransportMode.auto;
  int gpsInterval = 10; // seconds
  double distance = 0.0;
  double emission = 0.0;
  List<LocationData> locations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);

    DailyTrackerConfig.isDailyTrackedEnabled().then((isDailyTrackedEnabled2) =>
        setState(() => isDailyTrackerEnabled = isDailyTrackedEnabled2));
    DailyTrackerConfig.getTransportMode().then(
        (transportMode2) => setState(() => transportMode = transportMode2));
    DailyTrackerConfig.getGPSInterval()
        .then((gpsInterval2) => setState(() => gpsInterval = gpsInterval2));
    DailyTrackerConfig.getLocations()
        .then((locations2) => setState(() => locations = locations2));

    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  void startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      refreshStats();
    });
  }

  void toggleDailyTracker() {
    setState(() {
      isDailyTrackerEnabled = !isDailyTrackerEnabled;
    });
    DailyTrackerConfig.toggleDailyTracked(isDailyTrackerEnabled);
    if (!isDailyTrackerEnabled) {
      DailyTrackerConfig.updateUserTransportEmissions(emission, transportMode);
    }
  }

  void resetDailyTracker() {
    setState(() {
      distance = 0;
      emission = 0;
      locations = [];
    });
    DailyTrackerConfig.resetDailyTracked(false);
  }

  void transportModeChanged(TransportMode? newTransportMode) {
    setState(() {
      transportMode = newTransportMode ?? TransportMode.auto;
    });
    DailyTrackerConfig.setTransportMode(transportMode);
  }

  void gpsIntervalChanged(int? newGPSInterval) {
    setState(() {
      gpsInterval = newGPSInterval ?? 30;
    });
    DailyTrackerConfig.setGPSInterval(gpsInterval);
  }

  void refreshStats() async {
    (double, double) result = await DailyTrackerConfig.getResult();
    List<LocationData> locations2 = await DailyTrackerConfig.getLocations();

    setState(() {
      distance = result.$1;
      emission = result.$2;
      locations = locations2;
    });
  }

  Future<void> _moveCameraToFitMarkers(
      Completer<GoogleMapController> controllerr,
      Iterable<Marker> markers) async {
    final GoogleMapController controller = await controllerr.future;
    LatLngBounds bounds = _createLatLngBounds(markers);

    CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    await controller.animateCamera(cameraUpdate);
  }

  LatLngBounds _createLatLngBounds(Iterable<Marker> markers) {
    double? x0, x1, y0, y1;
    for (var marker in markers) {
      if (x0 == null || x1 == null || y0 == null || y1 == null) {
        x0 = x1 = marker.position.latitude;
        y0 = y1 = marker.position.longitude;
      } else {
        if (marker.position.latitude > x1) x1 = marker.position.latitude;
        if (marker.position.latitude < x0) x0 = marker.position.latitude;
        if (marker.position.longitude > y1) y1 = marker.position.longitude;
        if (marker.position.longitude < y0) y0 = marker.position.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = locations.map((location) => Marker(
        markerId: MarkerId(location.time.toString()),
        position: LatLng(location.latitude, location.longitude)));

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      home: Scaffold(
        body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
              child: Container(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Ionicons.analytics_outline,
                      color: Theme.of(context).colorScheme.onTertiary,
                      size: 30),
                  const SizedBox(width: 8),
                  Center(
                    child: Text(
                      "Daily Tracker",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Ionicons.help_circle_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Daily tracker information'),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'The rankings reflect the scores of users based on their ecological and sustainable activities.',
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Each user earns points by:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '- Contributing to green initiatives',
                                ),
                                Text(
                                  '- Choosing sustainable routes',
                                ),
                                Text(
                                  '- Responding to environmental quizzes',
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              color: Theme.of(context).colorScheme.tertiary,
              child: TabBar(
                controller: _tabController,
                tabs: tabs,
                dividerColor: Colors.transparent,
                labelStyle: Theme.of(context).textTheme.labelMedium,
                unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
                labelColor: Theme.of(context).colorScheme.onTertiary,
                indicatorColor: Theme.of(context).colorScheme.onTertiary,
              ),
            ),
            Expanded(
              child: Center(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              elevation: 6,
                              backgroundColor: isDailyTrackerEnabled
                                  ? const Color(0xF000CE90)
                                  : Color.fromARGB(255, 239, 72, 60),
                            ),
                            onPressed: toggleDailyTracker,
                            child: Icon(Ionicons.power,
                                size: 125,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                          const SizedBox(height: 40),
                          DropdownMenu<TransportMode>(
                            width: 200,
                            label: Text(
                              "Transport Mode",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary, // Texto do rótulo em branco
                              ),
                            ),
                            trailingIcon: Icon(
                              Ionicons.chevron_down_outline,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary, // Ícone secundário em branco
                            ),
                            selectedTrailingIcon: Icon(
                                Ionicons.chevron_up_outline,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                            leadingIcon: Icon(
                              transportMode.icon,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            inputDecorationTheme: InputDecorationTheme(
                              fillColor: Colors.black,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary, // Borda branca
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary, // Borda branca
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                            ),
                            initialSelection: transportMode,
                            onSelected: transportModeChanged,
                            requestFocusOnTap: false,
                            enableSearch: false,
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontFamily: "FredokaRegular",
                            ),
                            dropdownMenuEntries: TransportMode.values
                                .map((TransportMode transportMode) {
                              return DropdownMenuEntry<TransportMode>(
                                leadingIcon: Icon(
                                  transportMode.icon,
                                  color: Colors
                                      .black, // Ícones no menu suspenso em branco
                                ),
                                style: ButtonStyle(
                                  textStyle: MaterialStateProperty.all(
                                    TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      fontFamily: "FredokaRegular",
                                    ),
                                  ),
                                ),
                                value: transportMode,
                                label: transportMode.label,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 40),
                          DropdownMenu<int>(
                            width: 200,
                            label: Text(
                              "GPS Interval",
                              style: TextStyle(
                                fontFamily: "FredokaRegular",
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                            trailingIcon: Icon(
                              Ionicons.chevron_down_outline,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary, // Ícone secundário em branco
                            ),
                            selectedTrailingIcon: Icon(
                                Ionicons.chevron_up_outline,
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                            leadingIcon: Icon(
                              transportMode.icon,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            inputDecorationTheme: InputDecorationTheme(
                              fillColor: Colors.black,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary, // Borda branca
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(4.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary, // Borda branca
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                            ),
                            initialSelection: gpsInterval,
                            onSelected: gpsIntervalChanged,
                            requestFocusOnTap: false,
                            enableSearch: false,
                            textStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontFamily: "FredokaRegular",
                            ),
                            dropdownMenuEntries: gpsIntervalItems
                                .map(((int, String) gpsIntervalItem) {
                              return DropdownMenuEntry<int>(
                                  style: ButtonStyle(
                                    textStyle: MaterialStateProperty.all(
                                      TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        fontFamily: "FredokaRegular",
                                      ),
                                    ),
                                  ),
                                  value: gpsIntervalItem.$1,
                                  label: gpsIntervalItem.$2);
                            }).toList(),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 239, 72, 60),
                              elevation: 6,
                            ),
                            onPressed: resetDailyTracker,
                            child: Text(
                              "Reset",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text("Your Statistics",
                              style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: 10),
                          Card(
                            color: const Color(0xF000CE90),
                            child: ListTile(
                              leading: Icon(
                                Ionicons.location_outline,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                              title: Text('Distance',
                                  style:
                                      Theme.of(context).textTheme.displaySmall),
                              subtitle: Text(
                                  "${(distance / 1000).toStringAsFixed(3)} km",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            color: const Color(0xF000CE90),
                            child: ListTile(
                              leading: Icon(Icons.co2,
                                  color:
                                      Theme.of(context).colorScheme.onTertiary),
                              title: Text(
                                'Emission',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              subtitle: Text(
                                  "${emission.toStringAsFixed(3)} kg CO2",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium),
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 500,
                            child: EmissionChart(data: locations),
                          ),
                        ],
                      ),
                    ),
                    GoogleMap(
                      style: Provider.of<ThemeManager>(context).themeData ==
                              darkTheme
                          ? darkMapStyle
                          : lightMapStyle,
                      onMapCreated: (GoogleMapController gmController) {
                        Completer<GoogleMapController> controller = Completer();
                        controller.complete(gmController);
                        _moveCameraToFitMarkers(controller, markers);
                      },
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(39.3999, -8.2245),
                        zoom: 7.0,
                      ),
                      markers: markers.toSet(),
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points:
                              markers.map((marker) => marker.position).toList(),
                          color: Colors.teal,
                          width: 5,
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
