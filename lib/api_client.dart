import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 토큰을 가져와서 헤더에 추가
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioError error, handler) async {
        // 401 오류 처리
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await _reissueToken();
            if (newToken != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('auth_token', newToken);

              // 이전 요청을 복제하여 다시 시도
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $newToken';
              final cloneReq = await _dio.request(
                options.path,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
                data: options.data,
                queryParameters: options.queryParameters,
              );
              return handler.resolve(cloneReq);
            }
          } catch (e) {
            return handler.reject(error);
          }
        }
        return handler.reject(error);
      },
    ));
  }

  Future<String?> _reissueToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken != null) {
      try {
        final response = await _dio.post(
          'https://yourapi.com/auth/reissue',
          data: {'refresh_token': refreshToken},
        );
        if (response.statusCode == 200) {
          return response.data['new_token'];
        }
      } catch (e) {
        // 에러 처리
      }
    }
    return null;
  }

  // Example API request
  Future<Response> getData(String endpoint) async {
    return _dio.get(endpoint);
  }
}
