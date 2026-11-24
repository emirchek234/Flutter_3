import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/country_repository.dart';
import '../data/preferences_store.dart';
import '../data/token_interceptor.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  final store = PreferencesStore(preferences);
  getIt.registerSingleton<PreferencesStore>(store);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.api-ninjas.com/v1',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      sendTimeout: const Duration(seconds: 12),
      responseType: ResponseType.json,
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(ApiKeyInterceptor(store));
  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        compact: true,
      ),
    );
  }

  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<CountryRepository>(CountryRepository(dio));
}
