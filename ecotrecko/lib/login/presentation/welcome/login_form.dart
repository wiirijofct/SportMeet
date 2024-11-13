import 'package:ecotrecko/login/presentation/common/password_field.dart';
import 'package:flutter/material.dart';

class LoginFormData {
  final String username;
  final String password;
  final bool hasRememberMe;

  const LoginFormData(
      {required this.username,
      required this.password,
      required this.hasRememberMe});
}

enum LoginFormButton { login, signUp, forgotPassword }

class LoginForm extends StatefulWidget {
  final void Function(LoginFormButton, LoginFormData?) onButton;

  const LoginForm({super.key, required this.onButton});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hasRememberMe = false;

  void submitForm() {
    if (formKey.currentState!.validate()) {
      widget.onButton(
          LoginFormButton.login,
          LoginFormData(
              username: usernameController.text,
              password: passwordController.text,
              hasRememberMe: hasRememberMe));
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
              const Text("Login",
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
              PasswordField(
                labelText: 'Password',
                controller: passwordController,
                onFieldSubmitted: (_) => submitForm(),
                validator: (value) =>
                    value!.isEmpty ? "The password cannot be empty" : null,
              ),
              const SizedBox(height: 5),
              SizedBox(
                  width: double.maxFinite,
                  child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 20,
                      runSpacing: 5,
                      children: [
                        IntrinsicWidth(
                          child: Row(children: [
                            Checkbox(
                              value: hasRememberMe,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  hasRememberMe = newValue!;
                                });
                              },
                            ),
                            const Text("Remember me"),
                          ]),
                        ),
                        InkWell(
                          child: const Text('Forgot password?'),
                          onTap: () => {
                            widget.onButton(
                                LoginFormButton.forgotPassword, null)
                          },
                        )
                      ])),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: submitForm,
                    child: const Text("Login"),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        {widget.onButton(LoginFormButton.signUp, null)},
                    child: const Text("Sign up"),
                  ),
                ],
              )
            ]));
  }
}
