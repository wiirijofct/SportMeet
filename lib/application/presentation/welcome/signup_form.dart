import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/common/password_field.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:validators/validators.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SignUpFormData {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String countryCode;
  final String password;
  final String birthDate;
  final List<String> sports;
  final List<int> favFields;
  final List<int> reservations;
  final List<int> friends;
  final String imagePath;
  final bool hostUser;

  const SignUpFormData({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.countryCode,
    required this.password,
    required this.birthDate,
    required this.sports,
    this.favFields = const [],
    this.reservations = const [],
    this.friends = const [],
    this.imagePath = 'lib/images/m1.png',
    this.hostUser = false,
  });
}

enum SignUpFormButton { signUp, goBack }

class SignUpForm extends StatefulWidget {
  final void Function(SignUpFormButton, SignUpFormData?) onButton;

  const SignUpForm({super.key, required this.onButton});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final formKey = GlobalKey<FormState>();
  bool isSubmitting = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  late PhoneNumber phoneNumber;
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  String? birthDate;
  List<String> selectedSports = [];
  List<String> availableSports = [];
  bool isHostUser = false;
  static const String apiUrl = "http://localhost:3000";

  @override
  void initState() {
    super.initState();
    _loadAvailableSports();
  }

  Future<void> _loadAvailableSports() async {
  try {
    final response = await http.get(Uri.parse('$apiUrl/sports'));
    if (response.statusCode == 200) {
      final List<dynamic> sportsList = json.decode(response.body);
      setState(() {
        availableSports = sportsList.map((sport) => sport['name'].toString()).toList();
      });
    } else {
      throw Exception('Failed to load available sports');
    }
  } catch (e) {
    print('Error loading available sports: $e');
  }
}


  void submitForm() async {
  if (isSubmitting) return; // Prevent duplicate submissions

  if (formKey.currentState!.validate() && birthDate != null && selectedSports.isNotEmpty) {
    setState(() {
      isSubmitting = true; // Prevent further submissions during this one
    });

    final newUser = SignUpFormData(
      username: usernameController.text,
      email: emailController.text,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      phoneNumber: phoneNumber.number,
      countryCode: phoneNumber.countryCode,
      password: passwordController.text,
      birthDate: birthDate!,
      sports: selectedSports,
      hostUser: isHostUser,
    );

    // Save the new user using Authentication class method
    bool userCreated = await Authentication.createUser(
      newUser.username,
      newUser.email,
      newUser.firstName,
      newUser.lastName,
      newUser.phoneNumber,
      newUser.birthDate,
      newUser.sports,
      newUser.password,
      newUser.hostUser,
    );

    if (!mounted) {
      setState(() {
        isSubmitting = false; // Allow new submissions after completion
      });
      return;
    }

    setState(() {
      isSubmitting = false; // Allow new submissions after completion
    });

    if (userCreated) {
      widget.onButton(SignUpFormButton.signUp, newUser);
    } else {
      // Show an error message if the user already exists
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Username or email already exists."),
          );
        },
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.always,
        child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Sign Up",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLength: 30,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                    controller: usernameController,
                    onFieldSubmitted: (_) {},
                    validator: (value) =>
                        value!.isEmpty ? "The username cannot be empty" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    controller: emailController,
                    onFieldSubmitted: (_) {},
                    validator: (value) =>
                        isEmail(value!) ? null : "The email is not valid",
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                    ),
                    controller: firstNameController,
                    onFieldSubmitted: (_) {},
                    validator: (value) =>
                        value!.isEmpty ? "The first name cannot be empty" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    maxLength: 20,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                    ),
                    controller: lastNameController,
                    onFieldSubmitted: (_) {},
                    validator: (value) =>
                        value!.isEmpty ? "The last name cannot be empty" : null,
                  ),
                  const SizedBox(height: 15),
                  IntlPhoneField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    pickerDialogStyle:
                        PickerDialogStyle(padding: const EdgeInsets.all(30)),
                    initialCountryCode: "PT",
                    onChanged: (value) {
                      phoneNumber = value;
                    },
                    onSubmitted: (_) {},
                    validator: (value) => isNumeric(value!.number)
                        ? null
                        : "The phone number is not valid",
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    title: Text(birthDate == null ? 'Birth Date' : 'Birth Date: $birthDate'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900, 1, 1),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          birthDate = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  MultiSelectDialogField(
                    items: availableSports
                        .map((sport) => MultiSelectItem<String>(sport, sport))
                        .toList(),
                    title: const Text("Select Sports"),
                    buttonText: const Text("Select Sports"),
                    onConfirm: (values) {
                      setState(() {
                        selectedSports = values.cast<String>();
                      });
                    },
                    initialValue: selectedSports,
                    chipDisplay: MultiSelectChipDisplay.none(),
                  ),
                  const SizedBox(height: 15),
                  PasswordField(
                    labelText: 'Password',
                    controller: passwordController,
                    onFieldSubmitted: (_) {},
                    validator: (value) => Authentication.isPasswordCompliant(value!)
                        ? null
                        : '''
- A uppercase letter
- A lowercase letter
- A digit
- A special character
- A minimum length of ${Authentication.minPasswordLength} characters
 ''',
                  ),
                  const SizedBox(height: 15),
                  PasswordField(
                    labelText: 'Confirm Password',
                    controller: passwordController2,
                    onFieldSubmitted: (_) {},
                    validator: (value) => value == passwordController.text
                        ? null
                        : "The password is not the same",
                  ),
                  const SizedBox(height: 15),
                  CheckboxListTile(
                    title: const Text('Host User'),
                    value: isHostUser,
                    onChanged: (value) {
                      setState(() {
                        isHostUser = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: isSubmitting ? null : submitForm,
                        child: const Text("Sign up"),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            {widget.onButton(SignUpFormButton.goBack, null)},
                        child: const Text("Go back"),
                      ),
                    ],
                  )
                ])));
  }
}
