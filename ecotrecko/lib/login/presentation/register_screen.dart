import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:ecotrecko/file_selectors/file_selector.dart';
import 'package:ecotrecko/file_selectors/file_selector_mobile.dart';
import 'package:ecotrecko/file_selectors/file_selector_web.dart';
import 'package:ecotrecko/login/application/auth.dart';
import 'package:ecotrecko/login/presentation/common/centered_stretch.dart';
import 'package:ecotrecko/login/presentation/home/home_page.dart';
import 'package:ecotrecko/login/presentation/welcome/welcome_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _CreateUserScreenState();
}

extension NullIfEmpty on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

class _CreateUserScreenState extends State<RegisterScreen> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController countryCodeController;
  late TextEditingController passwordController;
  late TextEditingController confirmationController;
  late TextEditingController occupationController;
  late TextEditingController workplaceController;
  late TextEditingController addressController;
  late TextEditingController postcodeController;
  late TextEditingController taxpayerController;
  dynamic profilePicture;
  String? profilePictureUrl;
  bool uploadedPfp = false;
  late bool _passwordVisible;
  late bool _confirmationVisible;
  String avatarSeed = 'initialSeed';

  @override
  void initState() {
    usernameController = TextEditingController();
    emailController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    countryCodeController = TextEditingController();
    countryCodeController.text = "+351";
    passwordController = TextEditingController();
    confirmationController = TextEditingController();
    occupationController = TextEditingController();
    workplaceController = TextEditingController();
    addressController = TextEditingController();
    postcodeController = TextEditingController();
    taxpayerController = TextEditingController();

    _passwordVisible = false;
    _confirmationVisible = false;

    super.initState();
  }

  void onFileSelected() async {
    FileSelector fileSelector;
    if (kIsWeb) {
      fileSelector = FileSelectorWeb();
    } else {
      fileSelector = FileSelectorMobile();
    }

    profilePicture = await fileSelector.selectFile();
    print('Selected File: $profilePicture'); // Debug print
    if (profilePicture != null) {
      setState(() {
        uploadedPfp = true;
        profilePictureUrl = null; 
      });
    }
  }

  void generateRandomAvatar() {
    setState(() {
      avatarSeed = DateTime.now().millisecondsSinceEpoch.toString();
      profilePictureUrl = null;

      print('Generated Avatar Seed: $avatarSeed'); // Debug print
    });
  }

  Future<String?> generateRandomAvatarUrl(String seed) async {
    return 'https://api.multiavatar.com/$seed.png';
  }


Future<Uint8List?> generateRandomAvatarAsBytes(String seed, BuildContext context) async {
  if (kIsWeb) {
    final avatarUrl = 'https://api.multiavatar.com/$seed.png';
    try {
      final response = await http.get(Uri.parse(avatarUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load avatar');
      }
    } catch (e) {
      print('Error loading avatar: $e');
      return null;
    }
  } else {
    final GlobalKey repaintBoundaryKey = GlobalKey();
    Completer<Uint8List?> completer = Completer();

    final avatarWidget = RepaintBoundary(
      key: repaintBoundaryKey,
      child: RandomAvatar(seed, height: 100, width: 100),
    );

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Center(child: avatarWidget),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.delayed(const Duration(milliseconds: 100)); 

        final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: MediaQuery.of(context).devicePixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        completer.complete(byteData?.buffer.asUint8List());
      } catch (e) {
        completer.completeError(e);
      } finally {
        overlayEntry.remove();
      }
    });

    return completer.future;
  }
}


  Future<void> registerButtonPressed() async {
  try {
    String username = usernameController.text;
    String email = emailController.text;
    String name = nameController.text;
    String countryCode = countryCodeController.text;
    String phone = phoneController.text;
    String password = passwordController.text;
    String confirmation = confirmationController.text;

    bool pwCompliant = Authentication.isPasswordCompliant(password);
    bool emCompliant = Authentication.isEmailCompliant(email);

    if (password != confirmation) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Password does not match confirmation!"),
          );
        },
      );
      return;
    }

    if (!emCompliant) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Invalid email!"),
          );
        },
      );
      return;
    }

    if (!pwCompliant) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Invalid password format!"),
          );
        },
      );
      return;
    }

    // Step 1: Create the user
    bool userCreated = (await Authentication.createUser(
      username,
      email,
      name,
      countryCode,
      phone,
      password,
    )) as bool;

    print('User Created: $userCreated'); // Debug print

    if (!userCreated) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("User already exists or some fields are incorrect/missing!"),
          );
        },
      );
      return;
    }

    // Step 2: Upload the profile picture
    String? profilePicUrl;
    if (uploadedPfp && profilePicture != null) {
      print('Attempting to upload profile picture...'); // Debug print
      profilePicUrl = await Authentication.uploadImage(username, profilePicture);
      print('Uploaded Profile Picture URL: $profilePicUrl'); // Debug print
    } else {
      print('Generating random avatar...'); // Debug print

      final randomAvatarBytes = await generateRandomAvatarAsBytes(avatarSeed, context);

      if (randomAvatarBytes != null) {
        print('Attempting to upload generated avatar...'); // Debug print
        profilePicUrl = await Authentication.uploadImage(username, randomAvatarBytes);
        print('Uploaded Generated Avatar URL: $profilePicUrl'); // Debug print
      } else {
        profilePicUrl = "https://api.multiavatar.com/$avatarSeed.png";
        print('Using default Profile Picture URL: $profilePicUrl'); // Debug print
      }
    }

    // Step 3: Update the user profile with the profile picture URL
    print('Attempting to update user profile picture URL...'); // Debug print
    bool profileUpdated = await Authentication.updateUserProfilePic(username, profilePicUrl);
    print('Profile Updated: $profileUpdated'); // Debug print

    if (!profileUpdated) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Failed to update profile picture."),
          );
        },
      );
      return;
    }

    // Step 4: Show success dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text("Account created! To activate your account, click the link we sent to your email"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('Error: $e'); // Debug print
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("An error occurred: $e"),
        );
      },
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF000CE90), // Light green
              Color(0xFF02B5A0), // Dark green
            ],
          ),
        ),
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: CenteredStretch(
              maxWidth: 500,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 50.0),
                    child: Image(
                      image: AssetImage('lib/images/Logo.png'),
                      width: 300, // Set the width of the logo
                      height: 100, // Set the height of the logo
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      'Register!',
                      style: TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'FredokaRegular',
                      ),
                    ),
                  ),

                  // Profile Picture Preview
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profilePictureUrl != null
                              ? NetworkImage(profilePictureUrl!)
                              : null,
                          child: profilePictureUrl == null
                              ? RandomAvatar(avatarSeed,
                                  height: 100, width: 100)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: onFileSelected,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade800,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: generateRandomAvatar,
                        child: Text(
                          'Generate random avatar',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 16,
                            fontFamily: 'FredokaRegular',
                          ),
                        )),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 16,
                        fontFamily: 'FredokaRegular',
                      ),
                      controller: usernameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                          fontFamily: 'FredokaRegular',
                        ),
                      ),
                      onSubmitted: (_) => registerButtonPressed(),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 16,
                        fontFamily: 'FredokaRegular',
                      ),
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                          fontFamily: 'FredokaRegular',
                        ),
                      ),
                      onSubmitted: (_) => registerButtonPressed(),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 16,
                        fontFamily: 'FredokaRegular',
                      ),
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.person_2,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        labelText: 'Full Name',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                          fontFamily: 'FredokaRegular',
                        ),
                      ),
                      onSubmitted: (_) => registerButtonPressed(),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CountryCodePicker(
                          onChanged: (value) {
                            setState(() {
                              countryCodeController.text = value.toString();
                            });
                          },
                          initialSelection: 'PT',
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          showFlag: false,
                        ),
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 16,
                              fontFamily: 'FredokaRegular',
                            ),
                            controller: phoneController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              prefixIcon: Icon(
                                Ionicons.call_outline,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.transparent),
                              ),
                              labelText: 'Phone Number',
                              labelStyle: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontSize: 16,
                                fontFamily: 'FredokaRegular',
                              ),
                            ),
                            onSubmitted: (_) => registerButtonPressed(),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 16,
                        fontFamily: 'FredokaRegular',
                      ),
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                          fontFamily: 'FredokaRegular',
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => registerButtonPressed(),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: TextField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 16,
                        fontFamily: 'FredokaRegular',
                      ),
                      controller: confirmationController,
                      obscureText: !_confirmationVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onPrimary,
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontSize: 16,
                          fontFamily: 'FredokaRegular',
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmationVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmationVisible = !_confirmationVisible;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => registerButtonPressed(),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: ElevatedButton(
                      onPressed: registerButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 16,
                            fontFamily:
                                'FredokaRegular', // Applying the FredokaRegular font
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontSize: 20,
                        fontFamily: 'FredokaRegular',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomePage()));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                          fontFamily: "FredokaRegular"),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
