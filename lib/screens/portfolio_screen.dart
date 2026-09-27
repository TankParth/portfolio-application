import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config.dart';
import '../site_bridge.dart';
import '../theme.dart';
import '../theme_store.dart';
import '../widgets/intro_overlay.dart';
import '../widgets/offline_view.dart';
import '../widgets/pt_orb.dart';
import '../widgets/quick_actions_sheet.dart';
import '../widgets/section_dock.dart';

/// The app shell: live website in the middle, native dock + orb around it,
/// intro on top while the first load happens.
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key, required this.initialPalette});

  /// The theme the site was last in (from [ThemeStore]).
  final SitePalette initialPalette;

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  late final SiteBridge _bridge;

  int _progress = 0;
  bool _hasError = false;
  bool _pageLoaded = false;
  DateTime? _pausedAt;

  // Intro: shown until it has played AND the page is ready (or we give up waiting).
  bool _introPlayed = false;
  bool _introWaitExpired = false;
  bool _introGone = false;
  Timer? _introTimer;

  // Mirrored from the website via the bridge.
  String _section = 'about';
  late SitePalette _palette = widget.initialPalette;
  bool _userAgentSet = false;

  bool get _introVisible =>
      !(_introPlayed && (_pageLoaded || _hasError || _introWaitExpired));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.initialPalette.bg)
      ..addJavaScriptChannel(SiteBridge.channelName, onMessageReceived: _onBridgeMessage)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p),
        onPageStarted: (_) => setState(() => _hasError = false),
        onPageFinished: (_) {
          setState(() => _pageLoaded = true);
          _bridge.install();
        },
        onWebResourceError: (error) {
          // Only a failed page load means "offline"; a single broken
          // image or script shouldn't hide the whole site.
          if (error.isForMainFrame ?? true) setState(() => _hasError = true);
        },
        onNavigationRequest: _handleNavigation,
      ));
    _bridge = SiteBridge(_controller);
    _introTimer = Timer(introMaxWait, () => setState(() => _introWaitExpired = true));
    _loadFresh();
  }

  @override
  void dispose() {
    _introTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed && _pausedAt != null) {
      final away = DateTime.now().difference(_pausedAt!);
      _pausedAt = null;
      if (away >= staleAfter) _loadFresh();
    }
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    final state = SiteBridge.parse(message.message);
    if (state == null) return;
    if (state.palette != _palette) {
      applySystemBars(state.palette);
      ThemeStore.save(state.palette);
    }
    setState(() {
      _section = state.section;
      _palette = state.palette;
    });
  }

  /// Drops the HTTP cache so the latest deploy is always fetched.
  /// localStorage (e.g. the chosen theme) is kept.
  Future<void> _loadFresh() async {
    setState(() {
      _hasError = false;
      _progress = 0;
    });
    if (!_userAgentSet) {
      // Lets the site recognise the app (assets/js/platform.js → html.in-app).
      final ua = await _controller.getUserAgent();
      await _controller.setUserAgent('${ua ?? ''} $appUserAgentMarker'.trim());
      _userAgentSet = true;
    }
    await _controller.clearCache();
    await _controller.loadRequest(
      Uri.parse(siteUrl),
      headers: const {'Cache-Control': 'no-cache'},
    );
  }

  /// Keeps the portfolio inside the app; hands LinkedIn, GitHub, Drive,
  /// mailto:, etc. to the phone's own apps.
  Future<NavigationDecision> _handleNavigation(NavigationRequest request) async {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    final isSite =
        (uri.scheme == 'http' || uri.scheme == 'https') && uri.host == siteHost;
    if (isSite || uri.scheme == 'about' || uri.scheme == 'data') {
      return NavigationDecision.navigate;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return NavigationDecision.prevent;
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else if (_section != 'about') {
      // Back from deep in the page returns to the top before exiting.
      await _bridge.scrollTo('about');
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: p.bg,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        WebViewWidget(controller: _controller),
                        if (_progress < 100 && !_hasError && !_introVisible)
                          LinearProgressIndicator(
                            value: _progress / 100,
                            minHeight: 2,
                            color: p.accent,
                            backgroundColor: Colors.transparent,
                          ),
                        if (_hasError) OfflineView(palette: p, onRetry: _loadFresh),
                      ],
                    ),
                  ),
                ),
                if (!_hasError)
                  SectionDock(
                    palette: p,
                    activeSection: _section,
                    onSelect: _bridge.scrollTo,
                  ),
              ],
            ),
            if (!_hasError)
              Positioned(
                right: 16,
                bottom: bottomInset + 64 + 16,
                // Steps aside on the contact section so it never covers the form.
                child: AnimatedScale(
                  scale: _section == 'connect' ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: PtOrb(
                    palette: p,
                    onTap: () => showQuickActions(
                      context,
                      palette: p,
                      onRefresh: _loadFresh,
                    ),
                  ),
                ),
              ),
            if (!_introGone)
              IgnorePointer(
                ignoring: !_introVisible,
                child: AnimatedOpacity(
                  opacity: _introVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  onEnd: () {
                    if (!_introVisible) setState(() => _introGone = true);
                  },
                  child: IntroOverlay(
                    palette: widget.initialPalette,
                    onFinished: () => setState(() => _introPlayed = true),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
