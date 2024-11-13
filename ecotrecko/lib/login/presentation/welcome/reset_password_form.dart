import 'package:flutter/material.dart';
import 'package:validators/validators.dart';

class ResetPassowordFormData {
  final String username;
  final String email;

  const ResetPassowordFormData({
    required this.username,
    required this.email,
  });
}

enum ResetPassowordFormButton { resetPassword, goBack }

class ResetPassowordForm extends StatefulWidget {
  final void Function(ResetPassowordFormButton, ResetPassowordFormData?)
      onButton;

  const ResetPassowordForm({super.key, required this.onButton});

  @override
  State<ResetPassowordForm> createState() => _ResetPassowordFormState();
}

class _ResetPassowordFormState extends State<ResetPassowordForm> {
  final formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void submitForm() {
    if (formKey.currentState!.validate()) {
      widget.onButton(
          ResetPassowordFormButton.resetPassword,
          ResetPassowordFormData(
            username: usernameController.text,
            email: emailController.text,
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
              const Text("Reset Password",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
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
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: submitForm,
                    child: const Text("Reset Password"),
                  ),
                  OutlinedButton(
                    onPressed: () => {
                      widget.onButton(ResetPassowordFormButton.goBack, null)
                    },
                    child: const Text("Go back"),
                  ),
                ],
              )
            ]));
  }
}
