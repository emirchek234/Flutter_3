# Atlas — Country explorer

A Flutter app for exploring country facts from the [API Ninjas Country API](https://api-ninjas.com/api/country). Search for a country to see its capital, region, population, area, GDP, currency and life expectancy. Save places locally and revisit them without another request.

## Run it

1. Install Flutter (Dart 3.3 or newer) and an Android/iOS device or emulator.
2. From this repository, run `flutter create --platforms=android,ios .` once to generate the standard native launch/wrapper files for your local Flutter installation.
3. Run `flutter pub get`, then `flutter run`.
4. Create a free API Ninjas key at [api-ninjas.com](https://api-ninjas.com), tap the sliders/settings icon in Atlas, and save the key. Search a country name in English.

The app sends requests to `https://api.api-ninjas.com/v1/country?name=...`. The key is attached automatically as `X-Api-Key` by `ApiKeyInterceptor`; it is stored in the app's local preferences and is never committed to the repository. Do not ship a personal API key embedded in a public app. The Dio pretty logger is enabled in debug builds, with request headers and bodies disabled to avoid logging the credential.

## Project structure

- `lib/data/` — country model, API repository, preference persistence and token interceptor
- `lib/core/dependencies.dart` — Dio setup and `get_it` dependency registration
- `lib/features/explorer_screen.dart` — search, saved places, connection settings and result UI
- `test/` — model parsing and favorite-serialization coverage

## Packages used

`dio`, `pretty_dio_logger`, `get_it`, and `shared_preferences`.
