import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

import 'theme.dart';

/// What the page reported: the section in view and the live theme palette.
typedef SiteState = ({String section, SitePalette palette});

/// Two-way link between the native shell and the live website.
///
/// Page → app: an injected script posts JSON `{s, t, c}` over the
/// [channelName] channel whenever the visible section, the site's theme,
/// or its colour tokens change — `s` is the section id, `t` the
/// `data-theme` value and `c` the CSS custom properties in
/// [SitePalette.tokenNames]. Because the colours are read live, new
/// website themes need no app change.
/// App → page: [scrollTo] jumps to a section.
class SiteBridge {
  SiteBridge(this._controller);

  static const channelName = 'PTApp';

  final WebViewController _controller;

  static final _observerScript = '''
(function(){
  if (window.__ptBridge) return; window.__ptBridge = true;
  var html = document.documentElement;
  // Belt and braces: the site keys app-only CSS off this class (normally
  // set from the user agent by assets/js/platform.js), and the custom
  // cursor never makes sense on a touch screen.
  html.classList.add('in-app');
  var style = document.createElement('style');
  style.textContent = '#cursor,#cursor-ring{display:none!important}';
  document.head.appendChild(style);

  var ids = ['about','experience','skills','certifications','projects','about-anim','connect'];
  var tokens = ${jsonEncode(SitePalette.tokenNames)};
  var last = '';
  function report(){
    var cur = 'about';
    ids.forEach(function(id){
      var el = document.getElementById(id);
      if (el && el.getBoundingClientRect().top <= window.innerHeight * 0.35) cur = id;
    });
    var cs = getComputedStyle(html), colors = {};
    tokens.forEach(function(t){ colors[t] = cs.getPropertyValue('--' + t).trim(); });
    var msg = JSON.stringify({s: cur, t: html.getAttribute('data-theme') || 'dark', c: colors});
    if (msg !== last) { last = msg; PTApp.postMessage(msg); }
  }
  window.addEventListener('scroll', report, {passive: true});
  new MutationObserver(report).observe(html,
      {attributes: true, attributeFilter: ['data-theme', 'class', 'style']});
  report();
})();
''';

  /// Call after every page load; the script guards against double install.
  Future<void> install() => _controller.runJavaScript(_observerScript);

  Future<void> scrollTo(String sectionId) {
    final js = sectionId == 'about'
        ? "window.scrollTo({top: 0, behavior: 'smooth'});"
        : "var el = document.getElementById('$sectionId');"
            "if (el) el.scrollIntoView({behavior: 'smooth', block: 'start'});";
    return _controller.runJavaScript(js);
  }

  /// Parses a channel message; returns null if it isn't one of ours.
  static SiteState? parse(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final theme = data['t'] as String? ?? 'dark';
      final colors = (data['c'] as Map?)?.cast<String, dynamic>() ?? const {};
      return (
        section: data['s'] as String? ?? 'about',
        palette: SitePalette.fromTokens(theme, colors),
      );
    } catch (_) {
      return null;
    }
  }
}
