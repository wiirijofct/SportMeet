import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:ionicons/ionicons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecotrecko/login/application/auth.dart';
import 'package:dio/dio.dart';
import 'package:ecotrecko/dio/http_service.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  _MealsPageState createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  Map<String, dynamic> personalInformation = User.info;
  late CarouselController _controller;
  final Map<String, dynamic> _answers = {};
  final Map<int, String> _selectedOptions = {}; // Track selected options
  bool _showMeatQuestion = false;
  double _meatMealsSliderValue = 1.0;

  final List<Map<String, dynamic>> mealQuestions = [
    {
      'question': "What best describes your diet?",
      'options': ['Carnivore', 'Vegetarian', 'Omnivore'],
    },
    {
      'question': "How many times a week do you eat meat/fish?",
      'options': [],
    },
    {
      'question': "How often do you buy locally sourced products?",
      'options': ['Never', 'Sometimes', 'Most of the time'],
    },
    {
      'question': "How often do you buy organic foods?",
      'options': ['Never', 'Sometimes', 'Most of the time'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
  }

  Future<void> _onOptionSelected(int questionIndex, String option) async {
    setState(() {
      _answers[mealQuestions[questionIndex]['question']] = option;
      _selectedOptions[questionIndex] = option; // Update selected option
      if (questionIndex == 0) {
        _showMeatQuestion = option == 'Omnivore';
      }
    });

    try {
      // If not 'Omnivore', skip the meat/fish question slide by moving two pages if possible
      if (questionIndex == 0 && option != 'Omnivore') {
        // Check if there are enough slides to skip one
        if (mealQuestions.length > 2) {
          await _controller.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.linear);
        }
      }
      await _controller.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.linear);
        } catch (e) {
      print("Error navigating to the next page: $e");
    }
  }

  Future<void> _onSubmit() async {
    // Convert dietType to lowercase
    String dietType =
        (_answers["What best describes your diet?"] ?? '').toLowerCase();

    // Ensure meatMeals is within the specified range
    int meatMeals = _showMeatQuestion ? _meatMealsSliderValue.toInt() : 0;
    meatMeals =
        meatMeals.clamp(1, 13); // Assuming you want to enforce this range

    // Map values for locallySourced and organicFoods
    Map<String, String> valueMappings = {
      'Never': 'none',
      'Sometimes': 'some',
      'Most of the time': 'most',
    };

    String locallySourced = valueMappings[
            _answers["How often do you buy locally sourced products?"]] ??
        'none';
    String organicFoods =
        valueMappings[_answers["How often do you buy organic foods?"]] ??
            'none';

    // Add isDietCompleted as true
    Map<String, dynamic> formData = {
      'dietType': dietType,
      'meatMeals': meatMeals,
      'locallySourced': locallySourced,
      'organicFoods': organicFoods,
      'isDietCompleted': true, // Added this field
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
    items.addAll(mealQuestions.asMap().entries.map((entry) {
      int questionIndex = entry.key;
      var meal = entry.value;

      if (questionIndex == 1 && !_showMeatQuestion) {
        return Container(); // Skip the meat question if not needed
      }

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
                    meal['question'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'FredokaRegular',
                      fontSize: 24.0,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (meal['options'].isNotEmpty)
                    ...List<Widget>.generate(
                      meal['options'].length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _onOptionSelected(
                                questionIndex, meal['options'][index]);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedOptions[questionIndex] ==
                                    meal['options'][index]
                                ? Color.fromARGB(235, 49, 195, 147)
                                : const Color.fromARGB(185, 255, 255, 255),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            meal['options'][index],
                            style: const TextStyle(
                              fontFamily: 'FredokaRegular',
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (meal['question'] ==
                          "How many times a week do you eat meat/fish?" &&
                      _showMeatQuestion)
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
                            activeColor: Theme.of(context).colorScheme.tertiary,
                            secondaryActiveColor: Colors.white,
                            value: _meatMealsSliderValue,
                            min: 1,
                            max: 13,
                            divisions: 12,
                            label: _meatMealsSliderValue.round().toString(),
                            onChanged: (value) {
                              setState(() {
                                _meatMealsSliderValue = value;
                              });
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _onOptionSelected(questionIndex,
                                _meatMealsSliderValue.toString());
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
                        _meatMealsSliderValue = 1.0;
                        _showMeatQuestion = false;
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
                  Theme.of(context).colorScheme.surface,
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
                  Ionicons.restaurant_outline,
                  size: 50,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Meals',
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
