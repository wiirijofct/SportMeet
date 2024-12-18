import 'package:sport_meet/application/presentation/home/home_page.dart';
import 'package:sport_meet/application/presentation/welcome/login_form.dart';
import 'package:sport_meet/application/presentation/welcome/reset_password_form.dart';
import 'package:sport_meet/application/presentation/welcome/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:sport_meet/application/presentation/applogic/auth.dart';

void main() => runApp(const WelcomePage());

enum WelcomeForm { login, signUp, resetPassword }

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  WelcomeForm form = WelcomeForm.login;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    var loggedInUser = await Authentication.getLoggedInUser();
    if (loggedInUser != null) {
      // Navigate directly to HomePage if a user is already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Widget renderForm() {
    switch (form) {
      case WelcomeForm.signUp:
        return SignUpForm(onButton: (btn, data) async {
          switch (btn) {
            case SignUpFormButton.signUp:
              if (data != null) {
                // No longer call createUser here. Assume user creation is successful if this callback is triggered.
                showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      content: Text(
                          "Account created!"),
                    );
                  },
                );
                setState(() {
                  form = WelcomeForm.login;
                });
              }
              break;
            case SignUpFormButton.goBack:
            default:
              setState(() {
                form = WelcomeForm.login;
              });
              break;
          }
        });
      case WelcomeForm.resetPassword:
        return ResetPassowordForm(onButton: (btn, data) async {
          switch (btn) {
            case ResetPassowordFormButton.resetPassword:
              if (data != null) {
                String? errorMessage = await Authentication.resetPassword(
                  data.username,
                  data.email,
                );

                if (errorMessage == null) {
                  setState(() {
                    form = WelcomeForm.login;
                  });
                }

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        content: Text(errorMessage ??
                            "Check out the link we sent to your email to reset your password."));
                  },
                );
              }
              break;
            case ResetPassowordFormButton.goBack:
            default:
              setState(() {
                form = WelcomeForm.login;
              });
              break;
          }
        });
      default:
        return LoginForm(onButton: (btn, data) async {
          switch (btn) {
            case LoginFormButton.login:
              if (data != null) {
                bool loginSuccess = await Authentication.loginUser(
                  data.username,
                  data.password,
                  data.hasRememberMe,
                );

                if (loginSuccess) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        content: Text("The username or password is invalid"),
                      );
                    },
                  );
                }
              }
              break;
            case LoginFormButton.signUp:
              setState(() {
                form = WelcomeForm.signUp;
              });
              break;
            case LoginFormButton.forgotPassword:
              setState(() {
                form = WelcomeForm.resetPassword;
              });
              break;
            default:
              break;
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.green,
            scaffoldBackgroundColor: Colors.green.shade400,
            dialogBackgroundColor: Colors.white,
            checkboxTheme: CheckboxThemeData(
                side: const BorderSide(),
                fillColor: MaterialStateColor.resolveWith((states) =>
                    states.contains(MaterialState.selected)
                        ? Colors.green
                        : Colors.transparent)),
            inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green))),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )),
            outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              side: const BorderSide(
                color: Colors.green,
              ),
              foregroundColor: Colors.green,
            ))),
        home: Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/background.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: CustomScrollView(slivers: [
                  SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                            child: Container(
                                width: 400,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 20,
                                        offset: const Offset(0, 2),
                                      )
                                    ]),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Image(
                                        image:
                                            AssetImage('lib/images/Logo.png'),
                                        height: 50,
                                      ),
                                      const SizedBox(height: 10),
                                      renderForm()
                                    ]))),
                      )),
                ]))));
  }
}
