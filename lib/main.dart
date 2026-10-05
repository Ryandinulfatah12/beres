import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'db/repo.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  final repo = await Repo.open();
  final app = AppState(repo);
  await app.load();
  unawaited(app.syncWidget());
  runApp(ChangeNotifierProvider.value(value: app, child: const BeresApp()));
}

class BeresApp extends StatelessWidget {
  const BeresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beres?',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}
