import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The native UI's colours. Normally built live from the website's CSS
/// design tokens (see [SitePalette.fromTokens]), so any theme the site
/// adds — present or future — is matched without an app update.
/// The presets below mirror assets/css/variables.css and are only used
/// before the site has loaded, or if a token can't be read.
@immutable
class SitePalette {
  const SitePalette({
    required this.name,
    required this.bg,
    required this.bg2,
    required this.surface,
    required this.border,
    required this.accent,
    required this.accent2,
    required this.accent3,
    required this.text,
    required this.text2,
    required this.muted,
  });

  /// The site's `data-theme` value, e.g. `dark`, `light`, `retro`, `genz`.
  final String name;
  final Color bg;
  final Color bg2;
  final Color surface;
  final Color border;
  final Color accent;
  final Color accent2;
  final Color accent3;
  final Color text;
  final Color text2;
  final Color muted;

  /// Decided from the background itself, so it's right for any theme.
  bool get isDark => bg.computeLuminance() < .4;

  LinearGradient get brandGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accent2],
      );

  static const dark = SitePalette(
    name: 'dark',
    bg: Color(0xFF070710),
    bg2: Color(0xFF0D0D1A),
    surface: Color(0xFF111122),
    border: Color(0xFF1E1E35),
    accent: Color(0xFF7C6DFA),
    accent2: Color(0xFFFA6D9A),
    accent3: Color(0xFF3EEEA0),
    text: Color(0xFFEEEEF8),
    text2: Color(0xFFA0A0C0),
    muted: Color(0xFF5A5A80),
  );

  static const light = SitePalette(
    name: 'light',
    bg: Color(0xFFF5F5F7),
    bg2: Color(0xFFEBEBF0),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFD8D8E8),
    accent: Color(0xFF5B4DE0),
    accent2: Color(0xFFD0306E),
    accent3: Color(0xFF1A9E6A),
    text: Color(0xFF111128),
    text2: Color(0xFF444460),
    muted: Color(0xFF8888AA),
  );

  static const retro = SitePalette(
    name: 'retro',
    bg: Color(0xFFF3EAD3),
    bg2: Color(0xFFE9DCBC),
    surface: Color(0xFFFFFAF0),
    border: Color(0xFFCBB994),
    accent: Color(0xFF008080),
    accent2: Color(0xFFC2185B),
    accent3: Color(0xFFD48A00),
    text: Color(0xFF2B2118),
    text2: Color(0xFF5A4A3A),
    muted: Color(0xFF8C7A62),
  );

  static const genz = SitePalette(
    name: 'genz',
    bg: Color(0xFF0B0014),
    bg2: Color(0xFF14002A),
    surface: Color(0xFF1C0638),
    border: Color(0xFF3A0D6B),
    accent: Color(0xFFFF2BD6),
    accent2: Color(0xFF00F0FF),
    accent3: Color(0xFFC6FF00),
    text: Color(0xFFFFF7FF),
    text2: Color(0xFFE0CCFF),
    muted: Color(0xFFA88BDB),
  );

  static const presets = {'dark': dark, 'light': light, 'retro': retro, 'genz': genz};

  /// Built-in preset for a theme name; unknown names fall back to dark.
  static SitePalette of(String theme) => presets[theme] ?? dark;

  /// Token names read from the site (CSS custom properties without `--`).
  static const tokenNames = [
    'bg', 'bg2', 'surface', 'border', 'accent',
    'accent2', 'accent3', 'text', 'text2', 'muted',
  ];

  /// Builds a palette from the site's live CSS tokens. Any token that is
  /// missing or unparsable falls back to the matching preset's value.
  factory SitePalette.fromTokens(String theme, Map<String, dynamic> tokens) {
    final base = of(theme);
    Color pick(String key, Color fallback) =>
        parseCssColor(tokens[key]?.toString()) ?? fallback;
    return SitePalette(
      name: theme,
      bg: pick('bg', base.bg),
      bg2: pick('bg2', base.bg2),
      surface: pick('surface', base.surface),
      border: pick('border', base.border),
      accent: pick('accent', base.accent),
      accent2: pick('accent2', base.accent2),
      accent3: pick('accent3', base.accent3),
      text: pick('text', base.text),
      text2: pick('text2', base.text2),
      muted: pick('muted', base.muted),
    );
  }

  List<Color> get _colors =>
      [bg, bg2, surface, border, accent, accent2, accent3, text, text2, muted];

  Map<String, Object> toJson() => {
        'name': name,
        'tokens': {
          for (var i = 0; i < tokenNames.length; i++)
            tokenNames[i]: _toHex(_colors[i]),
        },
      };

  factory SitePalette.fromJson(Map<String, dynamic> json) => SitePalette.fromTokens(
        json['name'] as String? ?? 'dark',
        (json['tokens'] as Map?)?.cast<String, dynamic>() ?? const {},
      );

  @override
  bool operator ==(Object other) =>
      other is SitePalette &&
      other.name == name &&
      _colors.map((c) => c.toARGB32()).join() ==
          other._colors.map((c) => c.toARGB32()).join();

  @override
  int get hashCode => Object.hash(name, Object.hashAll(_colors.map((c) => c.toARGB32())));

  static String _toHex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

/// Parses the colour formats CSS custom properties are written in here:
/// `#rgb`, `#rrggbb`, `#rrggbbaa`, `rgb(r,g,b)` and `rgba(r,g,b,a)`.
Color? parseCssColor(String? value) {
  if (value == null) return null;
  final v = value.trim().toLowerCase();

  final hex = RegExp(r'^#([0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$').firstMatch(v);
  if (hex != null) {
    var h = hex.group(1)!;
    if (h.length == 3) h = h.split('').map((c) => '$c$c').join();
    if (h.length == 6) h = '${h}ff';
    final n = int.parse(h, radix: 16);
    // #rrggbbaa → 0xAARRGGBB
    return Color(((n & 0xFF) << 24) | (n >> 8));
  }

  final rgb = RegExp(r'^rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+)\s*)?\)$')
      .firstMatch(v);
  if (rgb != null) {
    final a = double.tryParse(rgb.group(4) ?? '1') ?? 1;
    return Color.fromARGB(
      (a.clamp(0, 1) * 255).round(),
      int.parse(rgb.group(1)!).clamp(0, 255),
      int.parse(rgb.group(2)!).clamp(0, 255),
      int.parse(rgb.group(3)!).clamp(0, 255),
    );
  }
  return null;
}

/// Colours the Android status and navigation bars to match [p].
void applySystemBars(SitePalette p) {
  final icons = p.isDark ? Brightness.light : Brightness.dark;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: p.bg,
    statusBarIconBrightness: icons,
    systemNavigationBarColor: p.bg2,
    systemNavigationBarIconBrightness: icons,
  ));
}
