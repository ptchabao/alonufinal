import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token is expired, try to refresh
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      
      if (refreshToken != null) {
        try {
          final dio = Dio();
          final response = await dio.post(
            '${AppConstants.apiBaseUrl}${AppConstants.refreshTokenEndpoint}',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newToken = response.data['accessToken'];
            final newRefreshToken = response.data['refreshToken'];

            await _secureStorage.write(key: AppConstants.tokenKey, value: newToken);
            await _secureStorage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);

            // Retry original request with new token
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            final retryResponse = await dio.request(opts.path, options: Options(
              method: opts.method,
              headers: opts.headers,
            ), data: opts.data, queryParameters: opts.queryParameters);

            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, clear storage and let it fail
          await _secureStorage.delete(key: AppConstants.tokenKey);
          await _secureStorage.delete(key: AppConstants.refreshTokenKey);
        }
      }
    }

    return handler.next(err);
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('>>> REQUEST: ${options.method} ${options.path}');
    print('>>> HEADERS: ${options.headers}');
    if (options.data != null) {
      print('>>> BODY: ${options.data}');
    }
    return handler.next(options);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    print('<<< RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    print('<<< DATA: ${response.data}');
    return handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    print('!!! ERROR: ${err.message}');
    print('!!! STATUS: ${err.response?.statusCode}');
    return handler.next(err);
  }
}
