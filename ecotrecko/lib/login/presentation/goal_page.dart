import 'package:ecotrecko/login/application/auth.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
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

class _GoalPageState extends State<GoalPage> {
  int _selectedIndex = 0;
  String searchQuery = '';
  GoalCategory? selectedCategory;
  List<Map<String, dynamic>> selectedGoals = [];

  late Future<Map<String, Map<String, dynamic>>> _goals;
  late Future<Map<String, Map<String, dynamic>>> _progress;
  late String username;

  @override
  void initState() {
    super.initState();
    _goals = Authentication.getGoals();
    username = User.info['username'];
    _progress = User.getGoalsProgress(username);
  }

  Widget _buildGoalWidget(String goalId, Map<String, dynamic> goal,
      Map<String, dynamic> userProgress) {
    IconData? iconData = categoryIcons[titleCategory[goal['category']]];
    bool isSelected = userProgress['track'];
    bool isGlobalGoal = _selectedIndex == 1;

    double progress = userProgress['points'] / goal['objective'];

    return Card(
      color: Theme.of(context).colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.onTertiaryContainer
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    userProgress['track'] = false;
                    User.updateGoals(username, goalId, userProgress);
                    selectedGoals.remove(goal);
                  } else {
                    userProgress['track'] = true;
                    User.updateGoals(username, goalId, userProgress);
                    selectedGoals.add(goal);
                  }
                });
              },
              leading: Icon(
                iconData,
                color: Theme.of(context).colorScheme.onTertiary,
                size: 36,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      goal['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        barrierColor: Colors.transparent,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              goal['title'],
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            icon: Icon(
                              iconData,
                              color: Theme.of(context).colorScheme.onTertiary,
                              size: 40,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal['why'],
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                            actions: [
                              TextButton(
                                child: Text(
                                  'Close',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Ionicons.information_circle_outline,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['subtitle'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (isGlobalGoal || isSelected)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (userProgress['points'] > 0) {
                                    userProgress['points'] -= 1;
                                    progress = userProgress['points'] /
                                        goal['objective'];
                                    User.updateGoals(
                                        username, goalId, userProgress);
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (userProgress['points'] <
                                      goal['objective']) {
                                    userProgress['points'] += 1;
                                    progress = userProgress['points'] /
                                        goal['objective'];
                                    User.updateGoals(
                                        username, goalId, userProgress);
                                    if (userProgress['points'] ==
                                        goal['objective']) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              '${goal['title']}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                            ),
                                            icon: Icon(
                                              iconData,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                              size: 40,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Have you completed this goal?',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                                const SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          userProgress[
                                                              'points'] = 0;
                                                          userProgress[
                                                              'track'] = false;
                                                          User.updateGoals(
                                                              username,
                                                              goalId,
                                                              userProgress);
                                                          selectedGoals
                                                              .remove(goal);
                                                          User.addScore(
                                                              username,
                                                              goal['points']);
                                                        });
                                                      },
                                                      child: Text('Yes',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onTertiary,
                                                              fontFamily:
                                                                  'FredokaRegular')),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        setState(() {
                                                          if (userProgress[
                                                                  'points'] >
                                                              0) {
                                                            userProgress[
                                                                'points'] -= 1;
                                                            User.updateGoals(
                                                                username,
                                                                goalId,
                                                                userProgress);
                                                          }
                                                        });
                                                      },
                                                      child: Text('Not yet',
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onTertiary,
                                                              fontFamily:
                                                                  'FredokaRegular')),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * goal['objective']).round()} out of ${goal['objective']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
              trailing: Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      userProgress['track'] = true;
                      User.updateGoals(username, goalId, userProgress);
                      selectedGoals.add(goal);
                    } else {
                      userProgress['track'] = false;
                      User.updateGoals(username, goalId, userProgress);
                      selectedGoals.remove(goal);
                    }
                  });
                },
                activeColor: Theme.of(context).colorScheme.onTertiaryContainer,
                checkColor: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              selected: isSelected,
              selectedTileColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterGoals(
      String query, Map<String, Map<String, dynamic>> goals) {
    if (query.isEmpty && selectedCategory == null) {
      return goals.values.toList();
    } else {
      return goals.values.where((goal) {
        final titleLower = goal['title'].toLowerCase();
        final searchLower = query.toLowerCase();
        final categoryMatch = selectedCategory == null ||
            titleCategory[goal['category']] == selectedCategory;
        return titleLower.contains(searchLower) && categoryMatch;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_goals, _progress]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var goals = snapshot.data![0];
          final filteredGoals = _filterGoals(searchQuery, goals);
          final displayedGoals =
              _selectedIndex == 0 ? filteredGoals : selectedGoals;

          var progress = snapshot.data![1];
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
                        Theme.of(context).colorScheme.primary,
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Icon(
                                    Ionicons.golf_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Goals',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Ionicons.help_circle_outline,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              'Goals Information',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium,
                                            ),
                                            icon: Icon(
                                              Ionicons.golf_outline,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                              size: 40,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Explore our pre-set eco goals, add them to your personal list, and track your progress with interactive progress bars. You can also add your own goals on your personal page. Complete goals to earn points and see your impact grow!',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  'Close',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
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
                            const SizedBox(height: 20),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedIndex = 0;
                                      });
                                    },
                                    child: Text(
                                      'Global Goals',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "FredokaRegular",
                                        fontWeight: FontWeight.bold,
                                        color: _selectedIndex == 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                                .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedIndex = 1;
                                      });
                                    },
                                    child: Text(
                                      'Your Goals',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "FredokaRegular",
                                        fontWeight: FontWeight.bold,
                                        color: _selectedIndex == 1
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onTertiary
                                                .withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search for goals...',
                                  hintStyle: TextStyle(
                                    fontFamily: 'FredokaRegular',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary
                                        .withOpacity(0.6),
                                  ),
                                  prefixIcon: Icon(
                                    Ionicons.search_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 20,
                                  ),
                                ),
                                style: TextStyle(
                                  fontFamily: 'FredokaRegular',
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: DropdownButton<GoalCategory?>(
                                value: selectedCategory,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedCategory = newValue;
                                  });
                                },
                                items: [
                                  DropdownMenuItem<GoalCategory?>(
                                    value: null,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Ionicons.options_outline,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'All Categories',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...GoalCategory.values.map((category) {
                                    return DropdownMenuItem<GoalCategory>(
                                      value: category,
                                      child: Row(
                                        children: [
                                          Icon(
                                            categoryIcons[category],
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onTertiary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            categoryTitles[category]!,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: displayedGoals
                                    .map((e) => _buildGoalWidget(
                                        e['id'], e, progress[e['id']]))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
