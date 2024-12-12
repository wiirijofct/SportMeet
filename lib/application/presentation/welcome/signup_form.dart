import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/common/custom_dropdown_form_field.dart';
import 'package:sport_meet/application/presentation/common/password_field.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:validators/validators.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final String gender;
  final List<String> availability;
  final String municipality;

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
    required this.gender,
    required this.availability,
    required this.municipality,
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
  TextEditingController phoneNumberController = TextEditingController();
  late PhoneNumber phoneNumber;
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  String? birthDate;
  List<String> selectedSports = [];
  List<String> availableSports = [];
  List<String> selectedAvailability = [];
  TextEditingController municipalityController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  String? gender;

  String? phoneNumberError;
  String? birthDateError;
  String? sportsError;
  String? availabilityError;

  bool isHostUser = false;
  static const String apiUrl = "http://localhost:3000";

  @override
  void initState() {
    super.initState();
    _loadAvailableSports();
    phoneNumber =
        PhoneNumber(countryCode: 'PT', number: '', countryISOCode: 'PT');
  }

  Future<void> _loadAvailableSports() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/sports'));
      if (response.statusCode == 200) {
        final List<dynamic> sportsList =
            json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          availableSports =
              sportsList.map((sport) => sport['name'].toString()).toList();
          availableSports.sort(); // Sort alphabetically
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

    // Validate standard fields (TextFormField, etc.)
    final isValid = formKey.currentState!.validate();

    // Manually validate custom fields
    bool customFieldsValid = true;

    // Validate phone number
    if (phoneNumber.number.isEmpty || !isNumeric(phoneNumber.number)) {
      customFieldsValid = false;
      setState(() {
        phoneNumberError = "The phone number is not valid";
      });
    } else {
      setState(() {
        phoneNumberError = null;
      });
    }

    // Validate birth date
    if (birthDate == null) {
      customFieldsValid = false;
      setState(() {
        birthDateError = "Please select a birth date";
      });
    } else {
      setState(() {
        birthDateError = null;
      });
    }

    // Validate availability
    if (selectedAvailability.isEmpty) {
      customFieldsValid = false;
      setState(() {
        availabilityError = "Please select your availability";
      });
    } else {
      setState(() {
        availabilityError = null;
      });
    }

    // Validate sports
    if (selectedSports.isEmpty) {
      customFieldsValid = false;
      setState(() {
        sportsError = "Please select at least one sport";
      });
    } else {
      setState(() {
        sportsError = null;
      });
    }

    // Check if all validations passed
    if (!isValid || !customFieldsValid) {
      return; // Stop submission if validation fails
    }

    // If validation passes, proceed with form submission
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
      gender: gender!,
      availability: selectedAvailability,
      municipality: municipalityController.text,
    );

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
      newUser.gender,
      newUser.availability,
      newUser.municipality,
    );

    setState(() {
      isSubmitting = false; // Allow new submissions after completion
    });

    if (userCreated) {
      widget.onButton(SignUpFormButton.signUp, newUser);
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.disabled,
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
              decoration: const InputDecoration(labelText: 'Username'),
              controller: usernameController,
              validator: (value) =>
                  value!.isEmpty ? "The username cannot be empty" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(labelText: 'Email'),
              controller: emailController,
              validator: (value) =>
                  isEmail(value!) ? null : "The email is not valid",
            ),
            const SizedBox(height: 15),
            TextFormField(
              maxLength: 20,
              decoration: const InputDecoration(labelText: 'First Name'),
              controller: firstNameController,
              validator: (value) =>
                  value!.isEmpty ? "The first name cannot be empty" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              maxLength: 20,
              decoration: const InputDecoration(labelText: 'Last Name'),
              controller: lastNameController,
              validator: (value) =>
                  value!.isEmpty ? "The last name cannot be empty" : null,
            ),
            const SizedBox(height: 15),
            IntlPhoneField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                errorText: phoneNumberError,
              ),
              pickerDialogStyle:
                  PickerDialogStyle(padding: const EdgeInsets.all(30)),
              initialCountryCode: "PT",
              onChanged: (value) {
                phoneNumber = value; // No need to validate the form here
              },
              validator: (value) => value != null && isNumeric(value.number)
                  ? null
                  : "The phone number is not valid",
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Gender'),
              value: gender,
              items: ['Male', 'Female', 'Other']
                  .map((label) => DropdownMenuItem(
                        child: Text(label),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  gender = value;
                  genderController.text = value ?? '';
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a gender' : null,
            ),
            const SizedBox(height: 15),
           FormField<List<String>>(
  initialValue: selectedAvailability,
  validator: (value) => value == null || value.isEmpty
      ? "Please select your availability"
      : null,
  builder: (state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchableDropdown<String>(
          items: [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ],
          value: selectedAvailability.isNotEmpty
              ? selectedAvailability.first
              : null,
          onChanged: (value) {
            if (value != null && !selectedAvailability.contains(value)) {
              setState(() {
                selectedAvailability.add(value);
              });
              state.didChange(selectedAvailability);
            }
          },
          itemToString: (day) => day,
          decoration: InputDecoration(
            labelText: 'Availability',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            hintText: 'Select or Search Availability',
          ),
          dropdownMaxHeight: 300.0,
          errorText: state.errorText,
        ),
        if (selectedAvailability.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectedAvailability.map((day) {
                return Chip(
                  label: Text(day),
                  onDeleted: () {
                    setState(() {
                      selectedAvailability.remove(day);
                    });
                    state.didChange(selectedAvailability);
                  },
                );
              }).toList(),
            ),
          ),
        if (state.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              state.errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  },
),
            const SizedBox(height: 15),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Municipality'),
              controller: municipalityController,
              validator: (value) =>
                  value!.isEmpty ? 'The municipality cannot be empty' : null,
            ),
            const SizedBox(height: 15),
            FormField<String>(
              initialValue: birthDate,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  value == null ? "Please select a birth date" : null,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Birth Date',
                        errorText: state.hasError ? state.errorText : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 0),
                      ),
                      child: ListTile(
                        title: Text(
                          birthDate == null
                              ? 'Select Birth Date'
                              : '$birthDate',
                          textAlign: birthDate == null
                              ? TextAlign.start
                              : TextAlign.center,
                        ),
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
                              birthDate =
                                  '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                            });
                            state.didChange(birthDate);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 15),
            FormField<List<String>>(
  initialValue: selectedSports,
  validator: (value) => value == null || value.isEmpty
      ? "Please select at least one sport"
      : null,
  builder: (state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchableDropdown<String>(
          items: availableSports,
          value: selectedSports.isNotEmpty
              ? selectedSports.first
              : null,
          onChanged: (value) {
            if (value != null && !selectedSports.contains(value)) {
              setState(() {
                selectedSports.add(value);
              });
              state.didChange(selectedSports);
            }
          },
          itemToString: (sport) => sport,
          decoration: InputDecoration(
            labelText: 'Sports',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            hintText: 'Select or Search Sports',
          ),
          dropdownMaxHeight: 300.0,
          errorText: state.errorText,
        ),
        if (selectedSports.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: selectedSports.map((sport) {
                return Chip(
                  label: Text(sport),
                  onDeleted: () {
                    setState(() {
                      selectedSports.remove(sport);
                    });
                    state.didChange(selectedSports);
                  },
                );
              }).toList(),
            ),
          ),
        if (state.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              state.errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  },
),
            const SizedBox(height: 15),
            PasswordField(
              labelText: 'Password',
              controller: passwordController,
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
          ],
        ),
      ),
    );
  }
}
