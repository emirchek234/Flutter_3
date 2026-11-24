import 'package:flutter/material.dart';

import 'app.dart';
import 'core/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const AtlasApp());
}
