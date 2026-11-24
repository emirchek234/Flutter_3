import 'package:atlas_network/data/country.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Country', () {
    test('parses API values and serializes favorites', () {
      final country = Country.fromJson({
        'name': 'Japan',
        'capital': 'Tokyo',
        'region': 'Asia',
        'population': 125000000,
        'surface_area': 377975,
        'gdp': 4231141000000,
        'currency': {'code': 'JPY', 'name': 'Japanese yen'},
        'iso2': 'JP',
        'life_expectancy': 84.8,
      });

      expect(country.name, 'Japan');
      expect(country.capital, 'Tokyo');
      expect(country.population, 125000000);
      expect(country.area, 377975);
      expect(country.currency, 'JPY');
      expect(country.lifeExpectancy, 84.8);

      final restored = Country.fromJson(country.toJson());
      expect(restored.name, country.name);
      expect(restored.currency, 'JPY');
      expect(restored.area, 377975);
    });

    test('accepts numeric strings and tolerates missing optional fields', () {
      final country = Country.fromJson({'name': 'Norway', 'population': '5500000'});
      expect(country.name, 'Norway');
      expect(country.population, 5500000);
      expect(country.capital, isNull);
      expect(country.gdp, isNull);
    });
  });
}
