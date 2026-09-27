import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

class DockItem {
  const DockItem(this.label, this.icon, this.target, this.covers);

  final String label;
  final IconData icon;

  /// Section id to scroll to.
  final String target;

  /// Section ids that light this item up while being read.
  final Set<String> covers;
}

const dockItems = [
  DockItem('Home', Icons.home_rounded, 'about', {'about'}),
  DockItem('Work', Icons.work_rounded, 'experience', {'experience'}),
  DockItem('Skills', Icons.bolt_rounded, 'skills', {'skills', 'certifications'}),
  DockItem('Projects', Icons.rocket_launch_rounded, 'projects', {'projects', 'about-anim'}),
  DockItem('Contact', Icons.forum_rounded, 'connect', {'connect'}),
];

/// Native bottom navigation for the website. The site hides its nav links
/// on phones, so this is the only quick way around — and it tracks the
/// section being read as the user scrolls.
class SectionDock extends StatelessWidget {
  const SectionDock({
    super.key,
    required this.palette,
    required this.activeSection,
    required this.onSelect,
  });

  final SitePalette palette;
  final String activeSection;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: palette.bg2,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (final item in dockItems)
                Expanded(
                  child: _DockButton(
                    item: item,
                    palette: palette,
                    active: item.covers.contains(activeSection),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelect(item.target);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.palette,
    required this.active,
    required this.onTap,
  });

  final DockItem item;
  final SitePalette palette;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? palette.accent : palette.muted;
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: active ? 16 : 10, vertical: 4),
              decoration: BoxDecoration(
                color: active ? palette.accent.withValues(alpha: .16) : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(item.icon, size: 22, color: color),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 280),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: .2,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
