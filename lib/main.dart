import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/portfolio_screen.dart';
import 'theme.dart';
import 'theme_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The site's phone layout is built for portrait; landscape leaves it a
  // thin strip between the status bar and the dock.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Open in whatever theme the site was last in.
  final palette = await ThemeStore.load();
  applySystemBars(palette);
  runApp(PortfolioApp(initialPalette: palette));
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key, required this.initialPalette});

  final SitePalette initialPalette;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parth Tank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: initialPalette.accent,
          brightness: initialPalette.isDark ? Brightness.dark : Brightness.light,
        ),
        scaffoldBackgroundColor: initialPalette.bg,
      ),
      home: PortfolioScreen(initialPalette: initialPalette),
    );
  }
}
