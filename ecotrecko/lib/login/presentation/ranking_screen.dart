import 'package:ecotrecko/login/application/user.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _globalRankings = [];
  List<Map<String, dynamic>> _friendRankings = [];
  bool _isLoading = true;
  Map<String, dynamic> personalInformation = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    await getPersonalInfo();
    await _fetchRankings();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getPersonalInfo() async {
    personalInformation = await User.getInfo();
  }

  Future<void> _fetchRankings() async {
    if (personalInformation.isNotEmpty) {
      _globalRankings = await User.getGlobalRankings();
      _friendRankings = await User.getRankInfo(personalInformation['username']);
    }
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
                  Theme.of(context).colorScheme.surface, // Light green
                  Theme.of(context).colorScheme.primary, // Dark green
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Ionicons.trophy_outline,
                        color: Theme.of(context).colorScheme.onTertiary,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rankings',
                        style: Theme.of(context).textTheme.titleLarge,
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
                                title: Text('Rankings Information',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium),
                                icon: Icon(Ionicons.trophy_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                    size: 40),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'The rankings reflect the scores of users based on their ecological and sustainable activities.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Each user earns points by:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '- Contributing to green initiatives',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    Text(
                                      '- Choosing sustainable routes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    Text(
                                      '- Responding to environmental quizzes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Close',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall),
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
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Track your Eco Choices, Amplify Green Voices.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "The rankings reflect the scores of users based on their ecological and sustainable activities. Each user is evaluated by their contribution to green initiatives and environmental practices.",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Rankings',
                    style: Theme.of(context).textTheme.labelMedium,
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
                          'Global Ranking',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "FredokaRegular",
                            fontWeight: FontWeight.bold,
                            color: _selectedIndex == 0
                                ? Theme.of(context).colorScheme.onTertiary
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
                          'Friends Ranking',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "FredokaRegular",
                            fontWeight: FontWeight.bold,
                            color: _selectedIndex == 1
                                ? Theme.of(context).colorScheme.onTertiary
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
                _isLoading
                    ? const CircularProgressIndicator()
                    : Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: [
                            if (_selectedIndex == 0) ...[
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double spacing = constraints.maxWidth * 0.05;
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildMedalAvatar(
                                        _globalRankings[1]['avatarURL'] ?? '',
                                        _globalRankings[1]['name'] ?? 'Unknown',
                                        _globalRankings[1]['points']
                                                ?.toString() ??
                                            '0',
                                        'silver',
                                        spacing,
                                      ),
                                      buildMedalAvatar(
                                        _globalRankings[0]['avatarURL'] ?? '',
                                        _globalRankings[0]['name'] ?? 'Unknown',
                                        _globalRankings[0]['points']
                                                ?.toString() ??
                                            '0',
                                        'gold',
                                        spacing,
                                      ),
                                      buildMedalAvatar(
                                        _globalRankings[2]['avatarURL'] ?? '',
                                        _globalRankings[2]['name'] ?? 'Unknown',
                                        _globalRankings[2]['points']
                                                ?.toString() ??
                                            '0',
                                        'bronze',
                                        spacing,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              buildPlacementList(_globalRankings.sublist(3)),
                            ] else ...[
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double spacing = constraints.maxWidth * 0.05;
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (_friendRankings.length > 1)
                                        buildMedalAvatar(
                                          _friendRankings[1]['avatarURL'] ?? '',
                                          _friendRankings[1]['name'] ??
                                              'Unknown',
                                          _friendRankings[1]['points']
                                                  ?.toString() ??
                                              '0',
                                          'silver',
                                          spacing,
                                        ),
                                      buildMedalAvatar(
                                        _friendRankings[0]['avatarURL'] ?? '',
                                        _friendRankings[0]['name'] ?? 'Unknown',
                                        _friendRankings[0]['points']
                                                ?.toString() ??
                                            '0',
                                        'gold',
                                        spacing,
                                      ),
                                      if (_friendRankings.length > 2)
                                        buildMedalAvatar(
                                          _friendRankings[2]['avatarURL'] ?? '',
                                          _friendRankings[2]['name'] ??
                                              'Unknown',
                                          _friendRankings[2]['points']
                                                  ?.toString() ??
                                              '0',
                                          'bronze',
                                          spacing,
                                        ),
                                    ],
                                  );
                                },
                              ),
                              if (_friendRankings.length > 3)
                                buildPlacementList(_friendRankings.sublist(3)),
                            ],
                          ],
                        ),
                      ),
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
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
          ),
        ],
      ),
    );
  }

  Widget buildMedalAvatar(String image, String name, String score,
      String medalType, double spacing) {
    Color medalColor;
    double avatarRadius;
    double fontSize;
    switch (medalType) {
      case 'gold':
        medalColor = const Color(0xFFFFD700); // Gold
        avatarRadius = 50;
        fontSize = 15;
        break;
      case 'silver':
        medalColor = const Color(0xFFC0C0C0); // Silver
        avatarRadius = 45;
        fontSize = 13;
        break;
      case 'bronze':
        medalColor = const Color(0xFFCD7F32); // Bronze
        avatarRadius = 40;
        fontSize = 11;
        break;
      default:
        medalColor = Colors.transparent;
        avatarRadius = 30;
        fontSize = 11;
    }
    return Column(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: medalColor,
          child: CircleAvatar(
            radius: avatarRadius - 4,
            backgroundImage: NetworkImage(image),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          medalType == 'gold'
              ? '1st Place'
              : medalType == 'silver'
                  ? '2nd Place'
                  : '3rd Place',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        Text(
          name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        Text(
          'Score: $score',
          style: TextStyle(
            color: Theme.of(context).textTheme.labelSmall!.color,
            fontSize: fontSize - 2,
          ),
        ),
      ],
    );
  }

  Widget buildPlacementList(List<Map<String, dynamic>> placements) {
    return Column(
      children: placements.asMap().entries.map((entry) {
        int index = entry.key + 4;
        Map<String, dynamic> placement = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Text(
                '${index}th', // Display only the position number
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(placement['avatarURL'] ?? ''),
              ),
              const SizedBox(width: 10),
              Text(
                placement['name'] ?? 'Unknown',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                'Score: ${placement['points']?.toString() ?? '0'}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.labelMedium!.color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
