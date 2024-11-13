import 'package:sport_meet/application/presentation/applogic/auth.dart';
import 'package:sport_meet/application/presentation/common/password_field.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:validators/validators.dart';

class SignUpFormData {
  final String username;
  final String email;
  final String name;
  final String phoneNumber;
  final String countryCode;
  final String password;

  const SignUpFormData({
    required this.username,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.countryCode,
    required this.password,
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

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  late PhoneNumber phoneNumber;
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();

  void submitForm() {
    if (formKey.currentState!.validate()) {
      widget.onButton(
          SignUpFormButton.signUp,
          SignUpFormData(
            username: usernameController.text,
            email: emailController.text,
            name: nameController.text,
            phoneNumber: phoneNumber.number,
            countryCode: phoneNumber.countryCode,
            password: passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.always,
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
                onFieldSubmitted: (_) => submitForm(),
                validator: (value) =>
                    value!.isEmpty ? "The username cannot be empty" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                controller: emailController,
                onFieldSubmitted: (_) => submitForm(),
                validator: (value) =>
                    isEmail(value!) ? null : "The email is not valid",
              ),
              const SizedBox(height: 15),
              TextFormField(
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'First and Last Name',
                ),
                controller: nameController,
                onFieldSubmitted: (_) => submitForm(),
                validator: (value) =>
                    value!.isEmpty ? "The full name cannot be empty" : null,
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
                onSubmitted: (_) => submitForm(),
                validator: (value) => isNumeric(value!.number)
                    ? null
                    : "The phone number is not valid",
              ),
              const SizedBox(height: 15),
              PasswordField(
                labelText: 'Password',
                controller: passwordController,
                onFieldSubmitted: (_) => submitForm(),
                // validator: (value) => Authentication.isPasswordCompliant(value!)
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
                onFieldSubmitted: (_) => submitForm(),
                validator: (value) => value == passwordController.text
                    ? null
                    : "The password is not the same",
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: submitForm,
                    child: const Text("Sign up"),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        {widget.onButton(SignUpFormButton.goBack, null)},
                    child: const Text("Go back"),
                  ),
                ],
              )
            ]));
  }
}
