import 'package:dio/dio.dart';

import 'country.dart';

class CountryRepository {
  CountryRepository(this._dio);
  final Dio _dio;

  Future<Country> findCountry(String query) async {
    final response = await _dio.get<List<dynamic>>(
      '/country',
      queryParameters: {'name': query.trim()},
    );
    final rows = response.data ?? const [];
    if (rows.isEmpty) {
      throw const CountryLookupException(
        'No match found. Try the country’s English name, such as Japan or Brazil.',
      );
    }
    final first = rows.first;
    if (first is! Map) {
      throw const CountryLookupException('The server returned an unexpected response.');
    }
    return Country.fromJson(Map<String, dynamic>.from(first));
  }
}

class CountryLookupException implements Exception {
  const CountryLookupException(this.message);
  final String message;

  @override
  String toString() => message;
}
