import 'dart:math';

import 'package:ecotrecko/login/application/directions.dart';
import 'package:ecotrecko/login/themes/dark_theme.dart';
import 'package:ecotrecko/login/themes/theme_manager.dart';
import 'package:ecotrecko/map_template/darkTemplate.dart';
import 'package:ecotrecko/map_template/lightTemplate.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final LatLng _origin = const LatLng(38.911962, -9.175329);
  final LatLng _destination = const LatLng(38.911962, -7.834997);
  final LatLng _midPoint = Directions.defaultLoc;
  final void Function() onPressed;

  MapCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: min(width * 0.9, 500),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 150,
            width: min(width * 0.9, 500),
            child: Stack(
              children: [
                GoogleMap(
                  style:
                      Provider.of<ThemeManager>(context).themeData == darkTheme
                          ? darkMapStyle
                          : lightMapStyle,
                  initialCameraPosition: CameraPosition(
                    target: _origin,
                    zoom: 6.0,
                  ),
                  markers: {
                    Marker(
                        markerId: const MarkerId('origin'), position: _origin),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: _destination,
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: [_origin, _midPoint, _destination],
                      color: Colors.green,
                      width: 3,
                    ),
                  },
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          icon,
                          size: 40,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
