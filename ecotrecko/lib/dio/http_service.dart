import 'package:dio/dio.dart';
import 'package:ecotrecko/dio/token_interceptor.dart';
import 'dio_mobile_adapter.dart' if (dart.library.html) 'dio_web_adapter.dart';

class HttpService {
  Future<Dio> createDio() async {
    return createDio2().then((dio) {
      dio.interceptors.add(TokenInterceptor());
      return dio;
    });
  }
}
