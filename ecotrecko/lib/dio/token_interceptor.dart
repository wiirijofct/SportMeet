import 'package:dio/dio.dart';
import 'package:ecotrecko/login/presentation/welcome/welcome_page.dart';
import 'package:ecotrecko/main.dart';
import 'package:flutter/material.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if the user is unauthorized
    if (err.response?.statusCode == 401) {
      if ((MyApp.navigatorKey.currentState != null &&
              MyApp.navigatorKey.currentState!.canPop()) ||
          false) {
        MyApp.navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomePage()));
      }
    }

    handler.next(err);
  }
}
