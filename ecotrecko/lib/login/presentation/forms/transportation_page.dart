// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:ionicons/ionicons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecotrecko/login/application/auth.dart';
import 'package:dio/dio.dart';
import 'package:ecotrecko/dio/http_service.dart';

const String HAS_VEHICLE_Q = "Do you have a personal vehicle?";
const String VEHICLE_TYPE_Q = "What category does your main vehicle fall into?";
const String FUEL_TYPE_Q = "What kind of fuel does it consume?";
const String FUEL_CONS_Q =
    "Approximately how much fuel in Liters does it consume per 100km?";

const String YES = "Yes";
const String NO = "No";
const String NOT_SURE = "Not sure";

const String DIESEL = "Diesel";
const String GASOLINE = "Gasoline";
const String GPL = "GPL";
const String HYBRID = "Hybrid";
const String ELECTRIC = "Electric";

const String SUV = "SUV";
const String SEDAN = "Sedan";
const String MICRO = "Micro Car";
const String MOTORCYCLE = "Motorcycle";

class TransportationPage extends StatefulWidget {
  const TransportationPage({super.key});

  @override
  TransportationPageState createState() => TransportationPageState();
}

class TransportationPageState extends State<TransportationPage> {
  Map<String, dynamic> personalInformation = User.info;
  late CarouselController _controller;
  final Map<String, dynamic> _answers = {};
  final Map<int, String> _selectedOptions = {}; // Track selected options
  bool _showGasQuestion = true;
  double _fuelConsumptionSliderValue = 4.0;

  final List<Map<String, dynamic>> transportationQuestions = [
    {
      'question': HAS_VEHICLE_Q,
      'options': [YES, NO],
    },
    {
      'question': VEHICLE_TYPE_Q,
      'options': [SUV, SEDAN, MICRO, MOTORCYCLE],
    },
    {
      'question': FUEL_TYPE_Q,
      'options': [DIESEL, GASOLINE, GPL, HYBRID, ELECTRIC],
    },
    {
      'question': FUEL_CONS_Q,
      'options': [NOT_SURE],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
  }

  Future<void> _onOptionSelected(int questionIndex, String option) async {
    setState(() {
      _answers[transportationQuestions[questionIndex]['question']] = option;
      _selectedOptions[questionIndex] = option;
      if (questionIndex == 2) {
        _showGasQuestion = option != ELECTRIC;
      }
    });

    try {
      if (questionIndex == 0 && option != YES) {
        _controller.jumpToPage(transportationQuestions.length - 1);
      }
      if (questionIndex == 2 && !_showGasQuestion) {
        _controller.jumpToPage(transportationQuestions.length - 1);
      }
      await _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    } catch (e) {
      print("Error navigating to the next page: $e");
    }
  }

  Future<void> _onSubmit() async {
    bool hasVehicle = _answers[HAS_VEHICLE_Q] == YES;

    // Ensure fuelConsumption is within the specified range
    int fuelConsumption =
        _showGasQuestion ? _fuelConsumptionSliderValue.toInt() : 0;
    fuelConsumption = fuelConsumption.clamp(4, 11); // Enforce the range

    String fuelType = _answers[FUEL_TYPE_Q] ?? 'none';
    String vehicleType = _answers[VEHICLE_TYPE_Q] ?? 'none';

    // Add isTransportationCompleted as true
    Map<String, dynamic> formData = {
      'hasVehicle': hasVehicle,
      'vehicleType': vehicleType,
      'fuelType': fuelType,
      'fuelConsumption': fuelConsumption,
      'isTransportationCompleted': true,
    };

    String url = '${Authentication.getUrl()}/form/update';

    try {
      HttpService httpService = HttpService();
      final dio = await httpService.createDio();
      final response = await dio.post(
        url,
        queryParameters: {"username": personalInformation["username"]},
        data: formData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          followRedirects: false,
        ),
      );

      if (response.statusCode == 200) {
        print("Form updated successfully");
        navigateToHomePage(context);
      } else {
        print("Failed to update form: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("DioException caught: ${e.message}");
    } catch (e) {
      print("General exception caught: ${e.toString()}");
    }
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    items.addAll(transportationQuestions.asMap().entries.map((entry) {
      int questionIndex = entry.key;
      var question = entry.value;

      return Builder(
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    question['question'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'FredokaRegular',
                      fontSize: 24.0,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (question['options'].isNotEmpty)
                    ...List<Widget>.generate(
                      question['options'].length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _onOptionSelected(
                                questionIndex, question['options'][index]);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOptions[questionIndex] ==
                                    question['options'][index]
                                ? const Color.fromARGB(235, 49, 195, 147)
                                : const Color.fromARGB(185, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            question['options'][index],
                            style: const TextStyle(
                              fontFamily: 'FredokaRegular',
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (question['question'] == FUEL_CONS_Q && _showGasQuestion)
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontFamily: "FredokaRegular",
                            ),
                          ),
                          child: Slider(
                            thumbColor:
                                Theme.of(context).colorScheme.onTertiary,
                            activeColor: Theme.of(context).colorScheme.tertiary,
                            value: _fuelConsumptionSliderValue,
                            min: 4.0,
                            max: 11.0,
                            divisions: 7,
                            label:
                                _fuelConsumptionSliderValue.toInt().toString(),
                            onChanged: (value) {
                              setState(() {
                                _fuelConsumptionSliderValue = value;
                              });
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _onOptionSelected(questionIndex,
                                _fuelConsumptionSliderValue.toInt().toString());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(185, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontFamily: 'FredokaRegular',
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    }).toList());

    items.add(
      Builder(
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Quiz Completed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'FredokaRegular',
                      fontSize: 24.0,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(185, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'FredokaRegular',
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _answers.clear();
                        _fuelConsumptionSliderValue = 4.0;
                        _showGasQuestion = true;
                        _selectedOptions.clear();
                      });
                      try {
                        _controller.animateToPage(0);
                      } catch (e) {
                        print("Error navigating to the first page: $e");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(185, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Retake',
                      style: TextStyle(
                        fontFamily: 'FredokaRegular',
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

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
                  Theme.of(context).colorScheme.background,
                  Theme.of(context).colorScheme.primary
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Ionicons.car_outline,
                  size: 50,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Transportation',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                    fontFamily: "FredokaRegular",
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                    child: CarouselSlider(
                      carouselController: _controller,
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.6,
                        autoPlay: false,
                        viewportFraction: 0.8,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false, // Disable infinite scroll
                      ),
                      items: items,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
