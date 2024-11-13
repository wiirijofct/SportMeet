import 'dart:typed_data';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/applogic/user.dart';
import 'package:ionicons/ionicons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  dynamic _profileImage;
  bool _editing = false;
  bool _changedPfp = false;

  Map<String, dynamic> personalInformation = User.info;
  Map<String, TextEditingController> controllers = {};
  int? _friendCount;
  List<Map<String, dynamic>> friends = [];

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  Future<void> getInfo() async {
    if (personalInformation.isEmpty) {
      personalInformation = await User.getInfo();
    }

    personalInformation.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });

    List<Map<String, dynamic>> friendList =
        await User.getFriends(personalInformation['username']);

    friends = friendList
        .where((friend) => friend['status'] == 'ACCEPTED')
        .map((friend) => {'name': friend['name']})
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _friendCount = friends.length;
      });
    });
  }

  void onFileSelected(Uint8List file) {
    setState(() {
      _changedPfp = true;
      _profileImage = file;
    });
  }

  @override
  Widget build(BuildContext context) {
    String avatarURL = personalInformation['avatarURL'] ?? '';
    String uniqueAvatarURL =
        '$avatarURL?${DateTime.now().millisecondsSinceEpoch}';
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
                            personalInformation["name"] ?? '',
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CountryCodePicker(
                            initialSelection:
                                personalInformation['countryCode'] ?? '',
                            textStyle: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_editing) {
                            controllers.forEach((key, value) {
                              value.text = personalInformation[key]?.toString() ?? '';
                            });
                          }
                          setState(() {
                            _editing = !_editing;
                          });
                        },
                        icon: _editing
                            ? Icon(
                                Icons.cancel_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              )
                            : Icon(
                                Icons.edit,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                      ),
                      if (_editing)
                        IconButton(
                          icon: const Icon(
                            Icons.save,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            bool updated = await User.updateInfo(
                              personalInformation['username'] ?? '',
                              controllers['email']?.text ?? '',
                              controllers['name']?.text ?? '',
                              controllers['countryCode']?.text ?? '',
                              controllers['phoneNumber']?.text ?? '',
                              controllers['profile']?.text ?? '',
                            );

                            if (_profileImage != null && _changedPfp) {
                              updated = await User.uploadProfilePicture(
                                  _profileImage as Uint8List);
                            } else {
                              _changedPfp = false;
                            }

                            if (updated) {
                              setState(() {
                                personalInformation['email'] =
                                    controllers['email']?.text;
                                personalInformation['name'] =
                                    controllers['name']?.text;
                                personalInformation['countryCode'] =
                                    controllers['countryCode']?.text;
                                personalInformation['phoneNumber'] =
                                    controllers['phoneNumber']?.text;
                                personalInformation['profile'] =
                                    controllers['profile']?.text;
                                _editing = false;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: personalInformation.entries.map((entry) {
                      if (entry.key == 'avatarURL' ||
                          entry.key == 'countryCode') return Container();
                      if (entry.key == "phoneNumber") {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone Number",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CountryCodePicker(
                                  textStyle: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      controllers['countryCode']?.text =
                                          value.toString();
                                    });
                                  },
                                  initialSelection:
                                      personalInformation['countryCode'] ?? '',
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                  showFlag: false,
                                  enabled: _editing,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: controllers[entry.key],
                                    readOnly: !_editing,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          125, 238, 238, 238),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalize(entry.key),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: controllers[entry.key],
                              readOnly: !_editing || entry.key == 'username',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: entry.key == 'username'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(125, 238, 238, 238),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
