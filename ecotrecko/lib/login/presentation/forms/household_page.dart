import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:ionicons/ionicons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:ecotrecko/dio/http_service.dart';
import 'package:ecotrecko/login/application/auth.dart';

class HouseholdPage extends StatefulWidget {
  const HouseholdPage({Key? key}) : super(key: key);

  @override
  _HouseholdPageState createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
  Map<String, dynamic> personalInformation = User.info;
  late CarouselController _controller;
  final Map<String, dynamic> _answers = {};
  final Map<int, dynamic> _selectedOptions = {};

  double _peopleSliderValue = 1.0;
  final Map<int, double> _fiveOptionsSliderValue = {};

  final List<Map<String, dynamic>> householdQuestions = [
    {
      'question': "What is the size of your house?",
      'options': ['Small', 'Medium', 'Large'],
    },
    {
      'question': "How many people live in your house?",
      'options': [],
    },
    {
      'question': "What is the energy efficiency of your house?",
      'options': ['None', 'Low', 'Medium', 'High', 'Very High'],
    },
    {
      'question':
          "Of the energy used in your house, what is the amount that is renewable?",
      'options': ['None', 'Low', 'Medium', 'High', 'Very High'],
    },
    {
      'question': "What is your waste production compared to your neighbors?",
      'options': ['Way less', 'Less', 'Same', 'More', 'Way more'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
  }

  Future<void> _onOptionSelected(int questionIndex, dynamic option) async {
    setState(() {
      _answers[householdQuestions[questionIndex]['question']] = option;
      _selectedOptions[questionIndex] = option;
    });

    try {
      await _controller.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.linear);
    } catch (e) {
      print("Error navigating to the next page: $e");
    }
  }

  Future<void> _onSubmit() async {
    int householdSize = _peopleSliderValue.toInt();
    String houseSize = _answers["What is the size of your house?"] ?? 'Small';
    String energyEfficiency =
        _answers["What is the energy efficiency of your house?"] ?? 'None';
    String renewableEnergy = _answers[
            "Of the energy used in your house, what is the amount that is renewable?"] ??
        'None';
    String wasteProduction =
        _answers["What is your waste production compared to your neighbors?"] ??
            'Same';
    bool isCompleted = true;

    Map<String, dynamic> formData = {
      'householdSize': householdSize,
      'houseSize': houseSize,
      'energyEfficiency': energyEfficiency,
      'renewableEnergy': renewableEnergy,
      'wasteProduction': wasteProduction,
      'isHabitationCompleted': isCompleted
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

  String getSliderLabel(int questionIndex, double value) {
    List<dynamic> options = householdQuestions[questionIndex]['options'];
    if (options.isNotEmpty) {
      // Ensure the index is within the bounds of the options list
      int index =
          value.toInt() - 1; // Convert 1-based slider value to 0-based index
      if (index >= 0 && index < options.length) {
        return options[index];
      }
    }
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = householdQuestions.asMap().entries.map((entry) {
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
                  if (questionIndex == 1)
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            valueIndicatorTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontFamily: "FredokaRegular",
                            ),
                          ),
                          child: Slider(
                            value: _peopleSliderValue,
                            thumbColor:
                                Theme.of(context).colorScheme.onTertiary,
                            activeColor: Theme.of(context).colorScheme.tertiary,
                            secondaryActiveColor: Colors.white,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _peopleSliderValue.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                _peopleSliderValue = value;
                              });
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _onOptionSelected(
                                questionIndex, _peopleSliderValue.toInt());
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
                    )
                  else if (question['options'].isNotEmpty)
                    Column(
                      children: [
                        if (questionIndex == 0)
                          Column(
                            children: List<Widget>.generate(
                              question['options'].length,
                              (index) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _onOptionSelected(questionIndex,
                                        question['options'][index]);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _selectedOptions[questionIndex] ==
                                                question['options'][index]
                                            ? Color.fromARGB(235, 49, 195, 147)
                                            : const Color.fromARGB(
                                                185, 255, 255, 255),
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
                          )
                        else if (question['options'].length == 5)
                          Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  valueIndicatorTextStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontFamily: "FredokaRegular",
                                  ),
                                ),
                                child: Slider(
                                  thumbColor:
                                      Theme.of(context).colorScheme.onTertiary,
                                  activeColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  value:
                                      _fiveOptionsSliderValue[questionIndex] ??
                                          1.0,
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  label: getSliderLabel(
                                    questionIndex,
                                    _fiveOptionsSliderValue[questionIndex] ??
                                        1.0,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _fiveOptionsSliderValue[questionIndex] =
                                          value;
                                    });
                                  },
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  int selectedIndex =
                                      (_fiveOptionsSliderValue[questionIndex]
                                                  ?.toInt() ??
                                              1) -
                                          1;
                                  if (selectedIndex >= 0 &&
                                      selectedIndex <
                                          householdQuestions[questionIndex]
                                                  ['options']
                                              .length) {
                                    _onOptionSelected(
                                        questionIndex,
                                        householdQuestions[questionIndex]
                                            ['options'][selectedIndex]);
                                  }
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
                          )
                      ],
                    )
                ],
              ),
            ),
          );
        },
      );
    }).toList();

    items.add(
      Builder(
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
                        _peopleSliderValue = 1.0;
                        _fiveOptionsSliderValue.clear();
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
                  Ionicons.home_outline,
                  size: 50,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Household',
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
                    height: 400,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: CarouselSlider(
                      carouselController: _controller,
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.6,
                        autoPlay: false,
                        viewportFraction: 0.8,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
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
