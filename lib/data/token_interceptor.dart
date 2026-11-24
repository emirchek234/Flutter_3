import 'package:dio/dio.dart';

import 'preferences_store.dart';

/// Adds the API Ninjas credential at request time, so changes in Settings take
/// effect immediately without rebuilding the Dio client.
class ApiKeyInterceptor extends Interceptor {
  ApiKeyInterceptor(this._store);

  final PreferencesStore _store;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _store.apiKey.trim();
    if (token.isNotEmpty) {
      options.headers['X-Api-Key'] = token;
    }
    handler.next(options);
  }
}
