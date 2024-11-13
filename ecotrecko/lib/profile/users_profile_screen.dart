import 'dart:io' as io;

import 'package:country_code_picker/country_code_picker.dart';
import 'package:ecotrecko/login/application/auth.dart';
import 'package:ecotrecko/login/application/directions.dart';
import 'package:ecotrecko/login/presentation/map_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/user.dart';

import 'package:ionicons/ionicons.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart'; // Verifique se este caminho está correto para importar a página inicial

class UsersProfileScreen extends StatefulWidget {
  const UsersProfileScreen(
      {super.key, required this.ownUsername, required this.profileUsername});
  final String profileUsername;
  final String ownUsername;

  @override
  State<UsersProfileScreen> createState() =>
      _UsersProfileScreenState(ownUsername, profileUsername);
}

enum GoalCategory {
  transportation,
  household,
  meals,
  shopping,
  outdoorActivities,
  health,
  others,
}

final Map<String, GoalCategory> titleCategory = {
  'Transportation': GoalCategory.transportation,
  'Household': GoalCategory.household,
  'Meals': GoalCategory.meals,
  'Shopping': GoalCategory.shopping,
  'Outdoor Activities': GoalCategory.outdoorActivities,
  'Health': GoalCategory.health,
  'Other': GoalCategory.others,
};

final Map<GoalCategory, String> categoryTitles = {
  GoalCategory.transportation: 'Transportation',
  GoalCategory.household: 'Household',
  GoalCategory.meals: 'Meals',
  GoalCategory.shopping: 'Shopping',
  GoalCategory.outdoorActivities: 'Outdoor Activities',
  GoalCategory.health: 'Health',
  GoalCategory.others: 'Other',
};

final Map<GoalCategory, IconData> categoryIcons = {
  GoalCategory.transportation: Ionicons.bus_outline,
  GoalCategory.household: Ionicons.home_outline,
  GoalCategory.meals: Ionicons.restaurant_outline,
  GoalCategory.shopping: Ionicons.cart_outline,
  GoalCategory.outdoorActivities: Ionicons.earth_outline,
  GoalCategory.health: Ionicons.fitness_outline,
  GoalCategory.others: Ionicons.leaf_outline,
};

class _UsersProfileScreenState extends State<UsersProfileScreen> {
  dynamic _profileImage;
  int? _friendCount;
  String? _profileVis;

  bool _showGoals = true;

  late Future<Map<String, dynamic>> _userInfo;
  List<Map<String, dynamic>> friendList = [];
  List<Map<String, dynamic>> friends = [];

  String profileUsername;
  String ownUsername;

  _UsersProfileScreenState(this.ownUsername, this.profileUsername);

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future<void> getInfo() async {
    _userInfo = User.getProfileInfo(widget.profileUsername);
  }

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  Icon getIcon(String category) {
    switch (category) {
      case 'water':
        return Icon(Ionicons.water, color: Colors.blue.shade400);
      case 'earth':
        return Icon(Ionicons.earth, color: Colors.brown.shade400);
      case 'plant':
        return Icon(Ionicons.leaf, color: Colors.green.shade400);
      default:
        return Icon(Icons.error, color: Colors.red.shade400);
    }
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
        future: _userInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userInfo = snapshot.data;
            String avatarURL = userInfo!['avatarURL'];
            String uniqueAvatarURL =
                '$avatarURL?${DateTime.now().millisecondsSinceEpoch}';

            _profileVis = userInfo['profile'];
            _friendCount = userInfo['friendCount'];
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Ionicons.arrow_back_circle_outline,
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _profileImage != null
                                      ? (kIsWeb
                                          ? MemoryImage(_profileImage)
                                              as ImageProvider<Object>
                                          : FileImage(_profileImage as io.File)
                                              as ImageProvider<Object>)
                                      : NetworkImage(uniqueAvatarURL)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "\t\t\t${userInfo['name']}",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "FredokaRegular",
                                    ),
                                  ),
                                  Text(
                                    "\t\t\t\t $profileUsername",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "FredokaRegular",
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      CountryCodePicker(
                                        initialSelection:
                                            userInfo['countryCode'],
                                        textStyle: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          fontSize: 16,
                                          fontFamily: "FredokaRegular",
                                        ),
                                        showCountryOnly: true,
                                        showOnlyCountryWhenClosed: true,
                                        alignLeft: false,
                                        enabled: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Container(
                              width: 150,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onPrimary,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  GestureDetector(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _friendCount.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                            fontFamily: "FredokaRegular",
                                          ),
                                        ),
                                        Text(
                                          _friendCount == 1
                                              ? "Friend"
                                              : 'Friends',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                            fontFamily: "FredokaRegular",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        userInfo['points'].toString(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                          fontFamily: "FredokaRegular",
                                        ),
                                      ),
                                      Text(
                                        'Score',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                          fontFamily: "FredokaRegular",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_profileVis == "Public" || userInfo['isFriend'])
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showGoals = true;
                                      });
                                    },
                                    child: Text(
                                      'Goals',
                                      style: TextStyle(
                                        color: _showGoals
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                                .withOpacity(0.5),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                // const SizedBox(width: 100),
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showGoals = false;
                                      });
                                    },
                                    child: Text(
                                      'Routes',
                                      style: TextStyle(
                                        color: !_showGoals
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                                .withOpacity(0.5),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_showGoals)
                              FutureBuilder<List<dynamic>>(
                                future: Future.wait([
                                  Authentication.getGoals(),
                                  User.getGoalsProgress(profileUsername)
                                ]),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    Map<String, Map<String, dynamic>> goals =
                                        snapshot.data![0];

                                    Map<String, Map<String, dynamic>> progress =
                                        snapshot.data![1];
                                    bool hasTrackedGoals = progress.entries.any(
                                        (element) => element.value['track']);

                                    if (hasTrackedGoals) {
                                      return  Column(
                                          children: goals.entries.map((goal) {
                                            var userProgress =
                                                progress[goal.key];
                                            if (userProgress!['track']) {
                                              return buildGoalCard(
                                                goal.value,
                                                userProgress,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary,
                                              );
                                            } else {
                                              return Container();
                                            }
                                          }).toList(),
                                      );
                                    } else {
                                      return Center(
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Icon(
                                              Ionicons.alert_outline,
                                              size: 50,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "User isn't tracking any goals.",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onTertiary,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ]));
                                    }
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              )
                            else
                              FutureBuilder<Map<String, Map<String, dynamic>>>(
                                future: Directions.fetchKnownDirections(
                                    widget.profileUsername),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var directions = snapshot.data!;

                                    if (directions.isNotEmpty) {
                                      return SingleChildScrollView(
                                          child: Column(
                                        children: _buildList(directions),
                                      ));
                                    } else {
                                      return Center(
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                            Icon(
                                              Ionicons.alert_outline,
                                              size: 50,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "User doesn't have public routes available.",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onTertiary,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ]));
                                    }
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              )
                          ],
                        ),
                      ),
                    if (_profileVis == "Private" && !userInfo['isFriend'])
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Ionicons.lock_closed_outline,
                                size: 50,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "This is a private profile",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  List<ListTile> _buildList(Map<String, Map<String, dynamic>> routeOrLocMap) {
    return routeOrLocMap.entries
        .map((entry) => ListTile(
            title:
                Text(entry.key, style: Theme.of(context).textTheme.labelMedium),
            subtitle: Text(
                "\t\t${entry.value['startAddr']}\n\t\t${entry.value['endAddr']}",
                style: Theme.of(context).textTheme.bodySmall),
            trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _saveRouteButton(entry),
                  _showRouteButton(entry),
                ])))
        .toList();
  }

  Future<Future> _saveRouteButtonPressed(String routeId) async {
    final TextEditingController routeController = TextEditingController();
    routeController.text = routeId;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Save Route',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onTertiary,
                fontWeight: FontWeight.bold),
          ),
          content: TextField(
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onTertiary),
              controller: routeController,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                border: const OutlineInputBorder(),
                labelText: 'Route Name',
                labelStyle: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onTertiary),
              )),
          actions: [
            TextButton(
              onPressed: () async {
                if (await Directions.shareDirections(profileUsername,
                    ownUsername, routeId, routeController.text)) {
                  Navigator.of(context).pop(true);
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
                        content: Text(
                            'Route saved successfully.\nCheck your map!',
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
                } else {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onTertiary)),
                        content: Text('Failed to save route',
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

  Row _saveRouteButton(MapEntry<String, Map<String, dynamic>> entry) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          _saveRouteButtonPressed(entry.key);
        },
        child: Icon(
          Ionicons.save_outline,
          size: 20,
          color: Theme.of(context).colorScheme.onTertiary,
        ),
      ),
    ]);
  }

  Row _showRouteButton(MapEntry<String, Map<String, dynamic>> entry) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 8),
      InkWell(
        onTap: () {
          // go to map page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(sharedRoute: entry),
            ),
          );
        },
        child: Icon(
          Ionicons.map_outline,
          size: 20,
          color: Theme.of(context).colorScheme.onTertiary,
        ),
      ),
    ]);
  }

  Widget buildGoalCard(Map<String, dynamic> goal,
      Map<String, dynamic> userProgress, Color textColor) {
    double progress = userProgress['points'] / goal['objective'];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  goal['subtitle'],
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Progress:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.green.shade400,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
