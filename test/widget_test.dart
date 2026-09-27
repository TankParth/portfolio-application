import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/config.dart';
import 'package:portfolio/site_bridge.dart';
import 'package:portfolio/theme.dart';
import 'package:portfolio/theme_store.dart';
import 'package:portfolio/widgets/section_dock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('points at the live portfolio over https', () {
    final uri = Uri.parse(siteUrl);
    expect(uri.host, siteHost);
    expect(uri.scheme, 'https');
  });

  group('parseCssColor', () {
    test('hex forms', () {
      expect(parseCssColor('#0b0014'), const Color(0xFF0B0014));
      expect(parseCssColor(' #FFF '), const Color(0xFFFFFFFF));
      expect(parseCssColor('#ff2bd680'), const Color(0x80FF2BD6));
    });
    test('rgb / rgba', () {
      expect(parseCssColor('rgb(0, 128, 128)'), const Color(0xFF008080));
      expect(parseCssColor('rgba(255,43,214,0)'), const Color(0x00FF2BD6));
    });
    test('rejects junk', () {
      expect(parseCssColor(null), isNull);
      expect(parseCssColor(''), isNull);
      expect(parseCssColor('linear-gradient(red, blue)'), isNull);
    });
  });

  group('SitePalette', () {
    test('presets exist for all four site themes', () {
      for (final t in ['dark', 'light', 'retro', 'genz']) {
        expect(SitePalette.of(t).name, t);
      }
      expect(SitePalette.of('unknown'), SitePalette.dark);
    });

    test('brightness is derived from the background', () {
      expect(SitePalette.dark.isDark, isTrue);
      expect(SitePalette.genz.isDark, isTrue);
      expect(SitePalette.light.isDark, isFalse);
      expect(SitePalette.retro.isDark, isFalse);
    });

    test('a brand-new site theme is built from its live tokens', () {
      final p = SitePalette.fromTokens('ocean', {'bg': '#001a2c', 'accent': '#00c2ff'});
      expect(p.name, 'ocean');
      expect(p.bg, const Color(0xFF001A2C));
      expect(p.accent, const Color(0xFF00C2FF));
      // missing tokens fall back to the default preset
      expect(p.text, SitePalette.dark.text);
      expect(p.isDark, isTrue);
    });

    test('json round trip', () {
      final back = SitePalette.fromJson(
          jsonDecode(jsonEncode(SitePalette.retro.toJson())) as Map<String, dynamic>);
      expect(back, SitePalette.retro);
    });
  });

  group('SiteBridge.parse', () {
    test('reads section, theme and tokens', () {
      final msg = jsonEncode({
        's': 'experience',
        't': 'genz',
        'c': {'bg': '#0b0014', 'accent': '#ff2bd6'},
      });
      final state = SiteBridge.parse(msg)!;
      expect(state.section, 'experience');
      expect(state.palette.name, 'genz');
      expect(state.palette.accent, const Color(0xFFFF2BD6));
    });

    test('ignores messages that are not ours', () {
      expect(SiteBridge.parse('about|dark'), isNull);
      expect(SiteBridge.parse('[1,2]'), isNull);
    });
  });

  group('ThemeStore', () {
    test('defaults to dark on first launch', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await ThemeStore.load(), SitePalette.dark);
    });

    test('remembers the last theme across launches', () async {
      SharedPreferences.setMockInitialValues({});
      await ThemeStore.save(SitePalette.genz);
      expect(await ThemeStore.load(), SitePalette.genz);
    });
  });

  test('every site section lights up exactly one dock item', () {
    const sections = ['about', 'experience', 'skills', 'certifications', 'projects', 'about-anim', 'connect'];
    for (final s in sections) {
      expect(dockItems.where((d) => d.covers.contains(s)), hasLength(1), reason: s);
    }
  });

  testWidgets('dock highlights the active section and reports taps', (tester) async {
    String? tapped;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: SectionDock(
          palette: SitePalette.genz,
          activeSection: 'certifications',
          onSelect: (id) => tapped = id,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    Color? labelColor(String label) => tester
        .widget<AnimatedDefaultTextStyle>(find
            .ancestor(of: find.text(label), matching: find.byType(AnimatedDefaultTextStyle))
            .first)
        .style
        .color;
    // Certifications belongs to the Skills tab.
    expect(labelColor('Skills'), SitePalette.genz.accent);
    expect(labelColor('Home'), SitePalette.genz.muted);

    await tester.tap(find.text('Projects'));
    expect(tapped, 'projects');
  });
}
