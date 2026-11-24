class Country {
  const Country({
    required this.name,
    this.capital,
    this.region,
    this.subregion,
    this.population,
    this.area,
    this.gdp,
    this.currency,
    this.iso2,
    this.iso3,
    this.lifeExpectancy,
  });

  final String name;
  final String? capital;
  final String? region;
  final String? subregion;
  final num? population;
  final num? area;
  final num? gdp;
  final String? currency;
  final String? iso2;
  final String? iso3;
  final num? lifeExpectancy;

  factory Country.fromJson(Map<String, dynamic> json) {
    String? text(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is Map) {
        final code = value['code']?.toString();
        final name = value['name']?.toString();
        return code ?? name;
      }
      if (value.toString().trim().isEmpty) return null;
      return value.toString();
    }

    num? number(String key) {
      final value = json[key];
      if (value is num) return value;
      return num.tryParse(value?.toString() ?? '');
    }

    return Country(
      name: text('name') ?? 'Unknown country',
      capital: text('capital'),
      region: text('region'),
      subregion: text('subregion'),
      population: number('population'),
      area: number('surface_area') ?? number('area'),
      gdp: number('gdp'),
      currency: text('currency'),
      iso2: text('iso2'),
      iso3: text('iso3'),
      lifeExpectancy: number('life_expectancy'),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'capital': capital,
        'region': region,
        'subregion': subregion,
        'population': population,
        'surface_area': area,
        'gdp': gdp,
        'currency': currency,
        'iso2': iso2,
        'iso3': iso3,
        'life_expectancy': lifeExpectancy,
      };
}
