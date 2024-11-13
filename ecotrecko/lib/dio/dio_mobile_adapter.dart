import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

Future<PersistCookieJar> getJar() async {
  var dir = await getApplicationDocumentsDirectory();
  return PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
}

Future<Dio> createDio2() async {
  var dio = Dio();
  var cookieJar = await getJar();
  dio.interceptors.add(CookieManager(cookieJar));
  return dio;
}
