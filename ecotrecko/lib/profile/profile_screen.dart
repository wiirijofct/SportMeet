import 'dart:io' as io;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:ecotrecko/file_selectors/file_selector.dart';
import 'package:ecotrecko/file_selectors/file_selector_mobile.dart';
import 'package:ecotrecko/file_selectors/file_selector_web.dart';
import 'package:ecotrecko/login/presentation/friends/friends_page.dart';
import 'package:ecotrecko/login/presentation/goal_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecotrecko/login/application/user.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  dynamic _profileImage;
  int? _friendCount;
  String? _profileVis;
  bool _editting = false;
  bool _changedPfp = false;

  Map<String, dynamic> personalInformation = User.info;
  Map<String, TextEditingController> controllers = {};
  List<Map<String, dynamic>> friendList = [];
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
    _profileVis = personalInformation['profile'];

    friendList = await User.getFriends(personalInformation['username']);

    List<Map<String, dynamic>> acceptedFriends =
        friendList.where((friend) => friend['status'] == 'ACCEPTED').toList();

    friends = acceptedFriends
        .map((friend) => {
              'name': friend['name'],
            })
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _friendCount = friends.length;
      });
    });
  }

  String newPassword = '';

  void navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  void onFileSelected() async {
    FileSelector fileSelector;
    if (kIsWeb) {
      fileSelector = FileSelectorWeb();
    } else {
      fileSelector = FileSelectorMobile();
    }

    final selectedFile = await fileSelector.selectFile();

    if (selectedFile != null) {
      setState(() {
        _changedPfp = true;
        _profileImage = selectedFile;
      });
    }
  }

  Icon getIcon(String tag) {
    switch (tag) {
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
    String avatarURL = personalInformation['avatarURL'];
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
                // ignore: deprecated_member_use
                color: Theme.of(context).colorScheme.background,
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
                              ? (kIsWeb
                                  ? MemoryImage(_profileImage)
                                      as ImageProvider<Object>
                                  : FileImage(_profileImage as io.File)
                                      as ImageProvider<Object>)
                              : NetworkImage(uniqueAvatarURL)),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            personalInformation["name"],
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "FredokaRegular",
                            ),
                          ),
                          CountryCodePicker(
                            initialSelection:
                                personalInformation['countryCode'],
                            textStyle: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 16,
                              fontFamily: "FredokaRegular",
                            ),
                            showCountryOnly: true,
                            showOnlyCountryWhenClosed: true,
                            alignLeft: false,
                            enabled: false, // Desabilitar a edição aqui
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FriendsPage(),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  _friendCount == 1 ? "Friend" : 'Friends',
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
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GoalPage(),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    personalInformation['points'].toString(),
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
                              )),
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () => {
                          if (_editting)
                            {
                              controllers.forEach((key, value) {
                                value.text =
                                    personalInformation[key].toString();
                              })
                            },
                          setState(() {
                            _editting = !_editting;
                          })
                        },
                        icon: _editting
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
                      if (_editting)
                        IconButton(
                          icon: const Icon(
                            Icons.save,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            bool updated = await User.updateInfo(
                              personalInformation['username']!,
                              controllers['email']!.text,
                              controllers['name']!.text,
                              controllers['countryCode']!.text,
                              controllers['phoneNumber']!.text,
                              controllers['profile']!.text,
                            );

                            if (_profileImage != null && _changedPfp) {
                              if (kIsWeb) {
                                updated = await User.uploadProfilePicture(
                                    _profileImage as Uint8List);
                              } else {
                                updated = await User.uploadProfilePicture(
                                    (_profileImage as io.File)
                                        .readAsBytesSync());
                              }
                            } else {
                              _changedPfp = false;
                            }

                            if (updated) {
                              setState(() {
                                personalInformation['email'] =
                                    controllers['email']!.text;
                                personalInformation['name'] =
                                    controllers['name']!.text;
                                personalInformation['countryCode'] =
                                    controllers['countryCode']!.text;
                                personalInformation['phoneNumber'] =
                                    controllers['phoneNumber']!.text;
                                personalInformation['profile'] =
                                    controllers['profile']!.text;
                                _editting = false;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_editting)
                    Column(
                      children: [
                        Center(
                          child: GestureDetector(
                              onTap: onFileSelected,
                              child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _profileImage != null
                                      ? (kIsWeb
                                          ? MemoryImage(_profileImage)
                                              as ImageProvider<Object>
                                          : FileImage(_profileImage as io.File)
                                              as ImageProvider<Object>)
                                      : NetworkImage(uniqueAvatarURL))),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: onFileSelected,
                            child: Text('Change Profile Picture',
                                style: TextStyle(
                                    fontFamily: 'FredokaRegular',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary)),
                          ),
                        ),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: personalInformation.entries.map((entry) {
                      if (entry.key == 'points' ||
                          entry.key == 'avatarURL' ||
                          entry.key == 'countryCode' ||
                          entry.key == 'roleCode' ||
                          entry.key == 'permissionCode') return Container();
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
                                fontFamily: "FredokaRegular",
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
                                    fontFamily: "FredokaRegular",
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      controllers['countryCode']!.text =
                                          value.toString();
                                    });
                                  },
                                  initialSelection:
                                      personalInformation['countryCode'],
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                  showFlag: false,
                                  enabled: _editting,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: controllers[entry.key],
                                    readOnly: !_editting ? true : false,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: "FredokaRegular",
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
                      } else if (entry.key == 'profile') {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                capitalize(entry.key),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: "FredokaRegular",
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton(
                                dropdownColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: "FredokaRegular",
                                ),
                                value: _profileVis,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Public', child: Text('Public')),
                                  DropdownMenuItem(
                                      value: 'Private', child: Text('Private')),
                                ],
                                onChanged: _editting
                                    ? (value) {
                                        setState(() {
                                          _profileVis = value.toString();
                                          controllers['profile']!.text =
                                              value.toString();
                                        });
                                      }
                                    : null,
                              )
                            ]);
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
                                fontFamily: "FredokaRegular",
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              maxLength: entry.key == 'username' ||
                                      entry.key == 'email'
                                  ? null
                                  : 40,
                              controller: controllers[entry.key],
                              readOnly: !_editting || entry.key == 'username'
                                  ? true
                                  : false,
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
}
