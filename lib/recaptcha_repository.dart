import 'package:dio/dio.dart';

class RecaptchaRepository {
  final Dio _dio = Dio();

  Future<bool> verify({required String token, required String siteKey}) async {
    _dio.options = BaseOptions(
      baseUrl: 'http://localhost:8080',
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final response = await _dio.post(
      '/verify',
      data: {
        'token': token,
        'siteKey': siteKey,
      },
    );

    if (response.data['success']) {
      return true;
    }

    return false;
  }
}
