import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:ionicons/ionicons.dart';

class UsersProfileScreen extends StatefulWidget {
  const UsersProfileScreen({super.key, required this.ownUsername, required this.profileUsername});
  final String profileUsername;
  final String ownUsername;

  @override
  State<UsersProfileScreen> createState() => _UsersProfileScreenState();
}

class _UsersProfileScreenState extends State<UsersProfileScreen> {
  dynamic _profileImage;
  int? _friendCount;
  String? _profileVis;

  late Future<Map<String, dynamic>> _userInfo;

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future<void> getInfo() async {
    _userInfo = User.getProfileInfo(widget.profileUsername);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userInfo = snapshot.data;
          String avatarURL = userInfo!['avatarURL'] ?? '';
          String uniqueAvatarURL = '$avatarURL?${DateTime.now().millisecondsSinceEpoch}';

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
                                color: Theme.of(context).colorScheme.onTertiary,
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
                                  ? MemoryImage(_profileImage)
                                  : NetworkImage(uniqueAvatarURL) as ImageProvider,
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${userInfo['name'] ?? ''}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "@${widget.profileUsername}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                CountryCodePicker(
                                  initialSelection: userInfo['countryCode'] ?? '',
                                  textStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    fontSize: 16,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _friendCount?.toString() ?? '0',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).colorScheme.onTertiary,
                                  ),
                                ),
                                Text(
                                  _friendCount == 1 ? "Friend" : 'Friends',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).colorScheme.onTertiary,
                                  ),
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
                          Text(
                            "This user has a public profile",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 16,
                            ),
                          ),
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
                                color: Theme.of(context).colorScheme.onTertiary,
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
      },
    );
  }
}
