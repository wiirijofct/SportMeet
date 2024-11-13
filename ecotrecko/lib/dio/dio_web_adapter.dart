import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

Future<Dio> createDio2() {
  var dio = Dio();
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
  return Future(() => dio);
}
