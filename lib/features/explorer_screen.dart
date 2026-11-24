import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/dependencies.dart';
import '../data/country.dart';
import '../data/country_repository.dart';
import '../data/preferences_store.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final _searchController = TextEditingController();
  final _repository = getIt<CountryRepository>();
  final _store = getIt<PreferencesStore>();
  Country? _country;
  bool _loading = false;
  String? _error;
  bool _favorite = false;

  static const _suggestions = ['Japan', 'Iceland', 'Brazil', 'New Zealand'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search([String? value]) async {
    final query = (value ?? _searchController.text).trim();
    if (query.isEmpty || _loading) return;
    _searchController.text = query;
    FocusScope.of(context).unfocus();
    if (_store.apiKey.isEmpty) {
      setState(() {
        _country = null;
        _error = 'Add your API Ninjas key to connect. It is saved only on this device.';
      });
      await _showSettings();
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final country = await _repository.findCountry(query);
      if (!mounted) return;
      setState(() {
        _country = country;
        _favorite = _store.isFavorite(country.name);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

  String _friendlyError(Object error) {
    if (error is CountryLookupException) return error.message;
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        return 'That API key was not accepted. Check it in connection settings.';
      }
      if (status == 429) return 'The API limit has been reached. Try again in a little while.';
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Could not reach API Ninjas. Check your connection and try again.';
      }
    }
    return 'Something went wrong while loading this country. Please try again.';
  }

  Future<void> _toggleFavorite() async {
    final country = _country;
    if (country == null) return;
    await _store.toggleFavorite(country);
    if (mounted) {
      setState(() => _favorite = _store.isFavorite(country.name));
    }
  }

  Future<void> _showSettings() async {
    final keyController = TextEditingController(text: _store.apiKey);
    var hidden = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFEFA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDADDD6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('Connect your API', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: Color(0xFF17332E))),
                  const SizedBox(height: 7),
                  const Text('Paste your API Ninjas key. It is stored locally and sent in the X-Api-Key header.', style: TextStyle(color: Color(0xFF65716B), height: 1.45)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: keyController,
                    obscureText: hidden,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      hintText: 'API key',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        onPressed: () => setSheetState(() => hidden = !hidden),
                        icon: Icon(hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await _store.saveApiKey(keyController.text);
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                        if (mounted && _searchController.text.trim().isNotEmpty) {
                          _search();
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Save connection'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Maybe later'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    keyController.dispose();
  }

  void _openFavorite(Country country) {
    setState(() {
      _country = country;
      _favorite = true;
      _error = null;
      _searchController.text = country.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _store.favorites;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
                  sliver: SliverList.list(
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 36),
                      _buildIntro(),
                      const SizedBox(height: 25),
                      _buildSearchCard(),
                      if (favorites.isNotEmpty) ...[
                        const SizedBox(height: 27),
                        _buildFavorites(favorites),
                      ],
                      const SizedBox(height: 28),
                      if (_loading) _buildLoading()
                      else if (_error != null) _buildError()
                      else if (_country != null) _buildCountry(_country!)
                      else _buildWelcome(),
                      const SizedBox(height: 36),
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() => Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: const Color(0xFF17332E), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.explore_rounded, color: Color(0xFFE2BB76), size: 23),
          ),
          const SizedBox(width: 11),
          const Text('atlas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.7, color: Color(0xFF17332E))),
          const Spacer(),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(14)),
            child: IconButton(
              tooltip: 'API connection settings',
              onPressed: _showSettings,
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF31594E)),
            ),
          ),
        ],
      );

  Widget _buildIntro() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFFE7EDE5), borderRadius: BorderRadius.circular(30)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.public_rounded, size: 15, color: Color(0xFF477263)),
              SizedBox(width: 6),
              Text('A LITTLE CLOSER TO EVERYWHERE', style: TextStyle(fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: Color(0xFF477263))),
            ]),
          ),
          const SizedBox(height: 17),
          const Text('The world,\nin a new light.', style: TextStyle(fontSize: 40, height: 1.02, fontWeight: FontWeight.w800, letterSpacing: -1.8, color: Color(0xFF17332E))),
          const SizedBox(height: 12),
          const Text('Look up a country and find the details that make it unique.', style: TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF65716B))),
        ],
      );

  Widget _buildSearchCard() => Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(21),
          boxShadow: const [BoxShadow(color: Color(0x0C17332E), blurRadius: 25, offset: Offset(0, 10))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.search_rounded, color: Color(0xFF839089)),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: const InputDecoration(hintText: 'Search a country', isDense: true, filled: false, contentPadding: EdgeInsets.symmetric(vertical: 13)),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _loading ? null : () => _search(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Explore'),
            ),
          ],
        ),
      );

  Widget _buildFavorites(List<Country> countries) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR SAVED PLACES', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: Color(0xFF87918A))),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: countries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final country = countries[index];
                return ActionChip(
                  onPressed: () => _openFavorite(country),
                  avatar: Text(_flag(country.iso2), style: const TextStyle(fontSize: 17)),
                  label: Text(country.name),
                  backgroundColor: const Color(0xFFE7EDE5),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                );
              },
            ),
          ),
        ],
      );

  Widget _buildWelcome() => Container(
        padding: const EdgeInsets.fromLTRB(20, 21, 20, 20),
        decoration: BoxDecoration(color: const Color(0xFFEBE9E1), borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Expanded(child: Text('Where to first?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF17332E)))),
              Icon(Icons.north_east_rounded, size: 19, color: const Color(0xFF477263)),
            ]),
            const SizedBox(height: 5),
            const Text('Try a popular destination to get started.', style: TextStyle(color: Color(0xFF65716B))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((name) => ActionChip(
                onPressed: () => _search(name),
                label: Text(name),
                backgroundColor: const Color(0xFFFFFEFA),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              )).toList(),
            ),
          ],
        ),
      );

  Widget _buildLoading() => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: const Color(0xFFFFFEFA), borderRadius: BorderRadius.circular(22)),
        child: const Row(children: [
          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
          SizedBox(width: 15),
          Text('Finding your destination…', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF65716B))),
        ]),
      );

  Widget _buildError() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFF7EAE6), borderRadius: BorderRadius.circular(20)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFB3483F)),
          const SizedBox(width: 12),
          Expanded(child: Text(_error!, style: const TextStyle(height: 1.45, color: Color(0xFF86443E)))),
          if (_store.apiKey.isEmpty)
            TextButton(onPressed: _showSettings, child: const Text('Connect')),
        ]),
      );

  Widget _buildCountry(Country country) => Container(
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x0A17332E), blurRadius: 25, offset: Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFF1F0EA), borderRadius: BorderRadius.circular(18)),
                child: Text(_flag(country.iso2), style: const TextStyle(fontSize: 31)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (country.region != null)
                    Text(country.region!.toUpperCase(), style: const TextStyle(fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w800, color: Color(0xFF759085))),
                  const SizedBox(height: 4),
                  Text(country.name, style: const TextStyle(fontSize: 26, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: Color(0xFF17332E))),
                  if (country.capital != null)
                    Padding(padding: const EdgeInsets.only(top: 4), child: Text('Capital · ${country.capital}', style: const TextStyle(fontSize: 13, color: Color(0xFF65716B)))),
                ]),
              ),
              IconButton(
                tooltip: _favorite ? 'Remove from saved places' : 'Save this place',
                onPressed: _toggleFavorite,
                icon: Icon(_favorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: const Color(0xFF477263)),
              ),
            ]),
            const SizedBox(height: 23),
            const Divider(height: 1, color: Color(0xFFEDECE6)),
            const SizedBox(height: 18),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth < 370 ? 1 : 2;
              final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
              final stats = <_StatData>[
                _StatData('POPULATION', _formatNumber(country.population), Icons.groups_2_outlined),
                _StatData('AREA', country.area == null ? '—' : '${_formatNumber(country.area)} km²', Icons.landscape_outlined),
                _StatData('GDP', country.gdp == null ? '—' : '\$${_formatNumber(country.gdp)}', Icons.account_balance_outlined),
                _StatData('LIFE EXPECTANCY', country.lifeExpectancy == null ? '—' : '${country.lifeExpectancy!.toStringAsFixed(1)} years', Icons.favorite_border_rounded),
              ];
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: stats.map((stat) => SizedBox(
                  width: width,
                  child: _statTile(stat),
                )).toList(),
              );
            }),
            if (country.subregion != null || country.currency != null || country.iso3 != null) ...[
              const SizedBox(height: 17),
              Wrap(spacing: 7, runSpacing: 7, children: [
                if (country.subregion != null) _tag(country.subregion!),
                if (country.currency != null) _tag(country.currency!),
                if (country.iso3 != null) _tag(country.iso3!),
              ]),
            ],
          ],
        ),
      );

  Widget _statTile(_StatData stat) => Container(
        constraints: const BoxConstraints(minHeight: 94),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFFF5F4EF), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(stat.icon, size: 16, color: const Color(0xFF759085)),
            const SizedBox(width: 6),
            Expanded(child: Text(stat.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800, color: Color(0xFF87918A)))),
          ]),
          const SizedBox(height: 9),
          Text(stat.value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF17332E))),
        ]),
      );

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFFE7EDE5), borderRadius: BorderRadius.circular(30)),
        child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF477263), fontWeight: FontWeight.w600)),
      );

  Widget _buildFooter() => const Center(
        child: Text('COUNTRY DATA · POWERED BY API NINJAS', style: TextStyle(fontSize: 9, letterSpacing: 1.1, fontWeight: FontWeight.w700, color: Color(0xFFA0A69F))),
      );

  String _formatNumber(num? value) {
    if (value == null) return '—';
    final integer = value.toInt();
    final digits = integer.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _flag(String? code) {
    if (code == null || code.length != 2) return '🌍';
    final upper = code.toUpperCase();
    return String.fromCharCodes(upper.codeUnits.map((unit) => 0x1F1E6 + unit - 0x41));
  }
}

class _StatData {
  const _StatData(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}
