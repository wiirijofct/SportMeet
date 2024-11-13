import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecotrecko/login/application/daily_tracker.dart';
import 'package:geolocator/geolocator.dart';

Color getColorForTransportMode(TransportMode transportMode) {
  switch (transportMode) {
    case TransportMode.car:
      return Colors.red;
    case TransportMode.bus:
      return Colors.blue;
    case TransportMode.bicycle:
      return Colors.green;
    case TransportMode.walking:
      return Colors.yellow;
    case TransportMode.train:
      return Colors.orange.shade400;
    case TransportMode.plane:
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

List<FlSpot> convertToFlSpots(List<LocationData> data) {
  List<FlSpot> newList = [];

  for (int i = 0; i < data.length; i++) {
    LocationData currLoc = data[i];

    double emission = 0;

    if (i > 0) {
      LocationData prevLoc = data[i - 1];

      double distanceInMeters = Geolocator.distanceBetween(prevLoc.latitude,
          prevLoc.longitude, currLoc.latitude, currLoc.longitude);
      double distanceInKm = distanceInMeters / 1000;

      emission += ((distanceInKm / 2) * currLoc.getTransportMode().getEmissionFactorBy(currLoc.speed));
    }

    if (i < data.length - 1) {
      LocationData nextLoc = data[i + 1];

      double distanceInMeters = Geolocator.distanceBetween(currLoc.latitude,
          currLoc.longitude, nextLoc.latitude, nextLoc.longitude);
      double distanceInKm = distanceInMeters / 1000;

      emission += ((distanceInKm / 2) * currLoc.getTransportMode().getEmissionFactorBy(currLoc.speed));
    }

    newList.add(FlSpot(currLoc.time.toDouble(), emission));
  }

  return newList;
}

class EmissionChart extends StatelessWidget {
  final List<LocationData> data;

  const EmissionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(4),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
                reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${date.hour}:${date.minute}:${date.second}',
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
              spots: convertToFlSpots(data),
              isCurved: false,
              barWidth: 4,
              belowBarData: BarAreaData(
                  show: true, color: Colors.lightBlue.withOpacity(0.2)),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final emissionData = data[index];
                  return FlDotCirclePainter(
                    radius: 4,
                    color: getColorForTransportMode(emissionData.getTransportMode()),
                    strokeWidth: 1,
                    strokeColor: Colors.black,
                  );
                },
              ),
              color: Colors.blue.withOpacity(0.5)),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final emissionData = data[touchedSpot.spotIndex];
                  return LineTooltipItem(
                    'Emission: ${touchedSpot.y.toStringAsFixed(4)} kg CO2\n'
                    'Transport Mode: ${emissionData.getTransportMode().label}\n'
                    'Time: ${DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt()).toString()}',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
              maxContentWidth: 300),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }
}
