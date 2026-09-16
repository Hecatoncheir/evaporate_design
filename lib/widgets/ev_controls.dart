import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import 'ev_icon.dart';

/// Второстепенная кнопка. Стеклянная, без заливки — рядом с «Играть»
/// она не должна претендовать на внимание.
class EvGhostButton extends StatefulWidget {
  const EvGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 56,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final String? icon;
  final double height;

  /// Красная кромка при наведении — для необратимого.
  final bool danger;

  @override
  State<EvGhostButton> createState() => _EvGhostButtonState();
}

class _EvGhostButtonState extends State<EvGhostButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final accent = widget.danger ? EvColors.bad : c.ink;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: EvMotion.fast,
          curve: EvMotion.ease,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: ev.radii.bPill,
            border: Border.all(
              color: _hover
                  ? (widget.danger ? EvColors.bad.withValues(alpha: 0.5) : c.ink4)
                  : c.line,
            ),
            color: c.surface.withValues(alpha: _hover ? 0.75 : 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                EvIcon(
                  widget.icon!,
                  size: 17,
                  color: _hover ? accent : c.ink2,
                ),
                const SizedBox(width: 9),
              ],
              Text(
                widget.label,
                style: ev.text.body.copyWith(color: _hover ? accent : c.ink2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Мелкое действие в строке. 30 px, только контур.
class EvMiniButton extends StatefulWidget {
  const EvMiniButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.danger = false,
  });

  final String label;
  final VoidCallback onPressed;
  final String? icon;
  final bool danger;

  @override
  State<EvMiniButton> createState() => _EvMiniButtonState();
}

class _EvMiniButtonState extends State<EvMiniButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final accent = widget.danger ? EvColors.bad : c.ink;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: EvMotion.fast,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: ev.radii.bPill,
            border: Border.all(
              color: _hover
                  ? (widget.danger ? EvColors.bad.withValues(alpha: 0.5) : c.ink4)
                  : c.line,
            ),
            color: _hover ? c.ink.withValues(alpha: 0.05) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                EvIcon(widget.icon!, size: 13, color: _hover ? accent : c.ink3),
                const SizedBox(width: 7),
              ],
              Text(
                widget.label,
                style: ev.text.bodySmall.copyWith(
                  color: _hover ? accent : c.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Тумблер. Включённый — единственное место, где акцент появляется
/// в строке настроек.
class EvSwitch extends StatelessWidget {
  const EvSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: EvMotion.ease,
            width: 44,
            height: 25,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: value
                  ? c.hot1.withValues(alpha: 0.26)
                  : c.ink.withValues(alpha: 0.08),
              border: Border.all(
                color: value ? c.hot1.withValues(alpha: 0.55) : c.line,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: EvMotion.ease,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 19,
                height: 19,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? null : c.ink3,
                  gradient: value
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [c.hot2, c.hot1],
                        )
                      : null,
                  boxShadow: value
                      ? [
                          BoxShadow(
                            color: c.hot1.withValues(alpha: 0.85),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Сегментированный выбор из двух-четырёх вариантов.
class EvSegmented<T> extends StatelessWidget {
  const EvSegmented({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final Map<T, String> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: ev.radii.bPill,
        border: Border.all(color: c.line),
        color: c.ground.withValues(alpha: 0.25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final e in items.entries)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(e.key),
                child: AnimatedContainer(
                  duration: EvMotion.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: ev.radii.bPill,
                    color: e.key == value
                        ? c.ink.withValues(alpha: 0.1)
                        : null,
                  ),
                  child: Text(
                    e.value,
                    style: ev.text.data.copyWith(
                      color: e.key == value ? c.ink : c.ink3,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Строка настройки: название, пояснение и один контрол справа.
class EvOption extends StatelessWidget {
  const EvOption({
    super.key,
    required this.title,
    required this.description,
    required this.control,
    this.last = false,
  });

  final String title;
  final String description;
  final Widget control;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: ev.colors.lineSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ev.text.body.copyWith(color: ev.colors.ink)),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: ev.text.bodySmall.copyWith(color: ev.colors.ink4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          control,
        ],
      ),
    );
  }
}
