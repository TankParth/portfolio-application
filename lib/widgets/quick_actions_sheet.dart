import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../theme.dart';

/// Native sheet of one-tap actions: share the portfolio, grab the resume,
/// reach out, or force-refresh the live site.
Future<void> showQuickActions(
  BuildContext context, {
  required SitePalette palette,
  required VoidCallback onRefresh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _QuickActionsSheet(
      palette: palette,
      onRefresh: () {
        Navigator.of(sheetContext).pop();
        onRefresh();
      },
    ),
  );
}

class _Action {
  const _Action(this.label, this.icon, this.tint, this.run);

  final String label;
  final IconData icon;
  final Color tint;
  final Future<void> Function() run;
}

class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({required this.palette, required this.onRefresh});

  final SitePalette palette;
  final VoidCallback onRefresh;

  static Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final actions = [
      _Action('Share', Icons.ios_share_rounded, p.accent, () async {
        await SharePlus.instance.share(ShareParams(
          text: Links.shareText,
          subject: 'Parth Tank — Portfolio',
        ));
      }),
      _Action('Resume', Icons.description_rounded, p.accent3, () => _open(Links.resume)),
      _Action('Email', Icons.mail_rounded, p.accent2, () => _open(Links.email)),
      _Action('LinkedIn', Icons.business_center_rounded, const Color(0xFF0A84C8),
          () => _open(Links.linkedin)),
      _Action('GitHub', Icons.code_rounded, p.text2, () => _open(Links.github)),
      _Action('Refresh', Icons.refresh_rounded, p.accent, () async => onRefresh()),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.border),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: p.muted.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: p.brandGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text('PT',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parth Tank',
                          style: TextStyle(
                              color: p.text, fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('Java · Spring Boot · React · Angular · Flutter',
                          style: TextStyle(color: p.muted, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.accent3.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: p.accent3.withValues(alpha: .3)),
                  ),
                  child: Text('Open to work',
                      style: TextStyle(color: p.accent3, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 22),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [for (final a in actions) _ActionTile(action: a, palette: p)],
            ),
            const SizedBox(height: 16),
            Text(
              'Content is live from $siteHost',
              style: TextStyle(color: p.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.palette});

  final _Action action;
  final SitePalette palette;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.bg2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          action.run();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: action.tint.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: action.tint, size: 22),
            ),
            const SizedBox(height: 8),
            Text(action.label,
                style: TextStyle(
                    color: palette.text, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
