import 'package:ecotrecko/login/presentation/common/wrapper.dart';
import 'package:ecotrecko/login/presentation/stats/stats_card.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:ionicons/ionicons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:intl/intl.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic> personalInformation = User.info;
  List<PieChartSectionData> pieChartSections = [];
  List<FlSpot> lineChartSpots = [];
  List<String> xAxisLabels = [];
  double dailyEmission = 1.61;
  double transportEmission = 0;
  double dietEmission = 0;
  double habitationEmission = 0;

  @override
  void initState() {
    super.initState();
    _updateDailyEmissions();
  }

  Future<void> _updateDailyEmissions() async {
    try {
      await User.calculateDailyEmissions();
      var response = await User.fetchDailyEmissions();

      if (response != null &&
          response is Map &&
          response.containsKey('totalEmission')) {
        var totalEmission = response['totalEmission'];
        transportEmission = response['transportEmission'];
        dietEmission = response['dietEmission'];
        habitationEmission = response['habitationEmission'];

        if (totalEmission is double &&
            transportEmission is double &&
            dietEmission is double &&
            habitationEmission is double) {
          setState(() {
            print("Daily emissions: $totalEmission");
            dailyEmission = totalEmission;
            // Update the pie chart data
            _updatePieChartData(transportEmission, dietEmission,
                habitationEmission, totalEmission);
          });

          // Fetch last 7 days emissions
          var lastSevenResponse = await User.fetchLastSevenEmissions();

          if (lastSevenResponse != null) {
            _updateLineChartData(lastSevenResponse);
          } else {
            print(
                "Failed to update last seven days emissions: response is invalid");
          }
        } else {
          print(
              "Failed to update daily emissions: One of the emissions is not a double");
        }
      } else {
        print("Failed to update daily emissions: response is invalid");
      }
    } catch (e) {
      print("Failed to update daily emissions: $e");
    }
  }

  void _updatePieChartData(double transportEmission, double dietEmission,
      double habitationEmission, double totalEmission) {
    // Calculate percentages
    double transportPercentage = (transportEmission / totalEmission) * 100;
    double dietPercentage = (dietEmission / totalEmission) * 100;
    double habitationPercentage = (habitationEmission / totalEmission) * 100;

    // Update pie chart sections
    pieChartSections = [
      PieChartSectionData(
        color: const Color.fromARGB(255, 201, 84, 41),
        value: habitationPercentage,
        title: 'Household',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        color: const Color.fromARGB(255, 238, 147, 34),
        value: dietPercentage,
        title: 'Meals',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      PieChartSectionData(
        color: const Color.fromARGB(255, 233, 184, 36),
        value: transportPercentage,
        title: 'Transportation',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];
  }

  void _updateLineChartData(Map<dynamic, dynamic> lastSevenEmissions) {
    List<FlSpot> spots = [];
    List<String> labels = [];

    DateTime today = DateTime.now();
    DateFormat dateFormat =
        DateFormat.E(); // Format for day of the week (e.g., Mon, Tue)

    // Iterate over the last 7 days, adding spots and labels
    for (int i = 0; i < 7; i++) {
      DateTime day = today
          .subtract(Duration(days: 6 - i)); // Start from 6 days ago to today
      double emission =
          lastSevenEmissions[6 - i] ?? 0.0; // Reverse index to match data order
      spots.add(FlSpot(i.toDouble(), emission));
      labels.add(dateFormat.format(day));
    }

    setState(() {
      lineChartSpots = spots;
      xAxisLabels = labels;
    });
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  List<PieChartSectionData> getSections() {
    return pieChartSections;
  }

  BarChartGroupData makeGroupData(
    int x,
    double y1, {
    bool isTouched = false,
    Color barColor = Colors.blue,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: isTouched ? Colors.yellow : barColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: false,
            toY: 20,
            color: Colors.grey[300],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> getBarGroups() {
    return [
      makeGroupData(0, dailyEmission,
          barColor: const Color.fromARGB(255, 201, 84, 41)),
      makeGroupData(1, 11.23,
          barColor: const Color.fromARGB(255, 238, 147, 34)),
      makeGroupData(2, 12.88,
          barColor: const Color.fromARGB(255, 233, 184, 36)),
    ];
  }

  LineChartData getLineChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                fontFamily: 'FredokaRegular',
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
              String text = '';
              if (value.toInt() >= 0 && value.toInt() < xAxisLabels.length) {
                text = xAxisLabels[value.toInt()];
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8.0,
                child: Text(text, style: style),
              );
            },
            reservedSize: 32,
            interval: 1, // Ensures only one label per day
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 20,
      lineBarsData: [
        LineChartBarData(
          spots: lineChartSpots,
          isCurved: true,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget buildPieChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double chartSize = constraints.maxWidth * 0.9; // Adjust as needed
        return Column(
          children: [
            buildGraphContainer(
              context,
              AspectRatio(
                aspectRatio: 1.0, // Aspect ratio 1:1 for PieChart
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: getSections(),
                        sectionsSpace: 6,
                        centerSpaceRadius:
                            chartSize * 0.3, // Adjust center space radius
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$dailyEmission kg',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CO2/day',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            buildEmissionDetails()
          ],
        );
      },
    );
  }

  Widget buildEmissionDetails() {
    double transportPercentage = (transportEmission / dailyEmission) * 100;
    double dietPercentage = (dietEmission / dailyEmission) * 100;
    double habitationPercentage = (habitationEmission / dailyEmission) * 100;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diet emission: ${dietEmission.toStringAsFixed(1)} kg / ${dietPercentage.toStringAsFixed(1)}% of total',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Habitation emission: ${habitationEmission.toStringAsFixed(1)} kg / ${habitationPercentage.toStringAsFixed(1)}% of total',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Transport emission: ${transportEmission.toStringAsFixed(1)} kg / ${transportPercentage.toStringAsFixed(1)}% of total',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildBarChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return buildGraphContainer(
          context,
          AspectRatio(
            aspectRatio: 1.5, // Aspect ratio for BarChart and LineChart
            child: BarChart(
              BarChartData(
                maxY: 20,
                barGroups: getBarGroups(),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontFamily: 'FredokaRegular',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = const Text('You', style: style);
                            break;
                          case 1:
                            text = const Text('Portugal', style: style);
                            break;
                          case 2:
                            text = const Text('World', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0,
                          child: text,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLineChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return buildGraphContainer(
          context,
          AspectRatio(
            aspectRatio: 1.5, // Aspect ratio for BarChart and LineChart
            child: LineChart(
              getLineChartData(),
            ),
          ),
        );
      },
    );
  }

  Widget buildGraphContainer(BuildContext context, Widget graph) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: graph,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.background, // Light green
                  Theme.of(context).colorScheme.primary, // Dark green
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Icon(
                      Ionicons.bar_chart_outline,
                      color: Theme.of(context).colorScheme.onTertiary,
                      size: 40,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ]),
                ),
                const SizedBox(height: 30),
                Wrapper(maxWidth: 400, gap: 15, children: [
                  StatsCard(
                      icon: Ionicons.leaf_outline,
                      title: 'Your CO2 Footprint',
                      child: buildPieChart(context)),
                  StatsCard(
                      icon: Ionicons.people_outline,
                      title: 'You vs. Community',
                      child: buildBarChart(context)),
                  StatsCard(
                      icon: Ionicons.trending_up_outline,
                      title: 'Emissions History',
                      child: buildLineChart(context))
                ]),
                const SizedBox(height: 15),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
