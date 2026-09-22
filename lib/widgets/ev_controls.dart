import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../glass/ev_droplet.dart';
import '../glass/ev_glass.dart';
import 'ev_focusable.dart';
import 'ev_icon.dart';

/// Второстепенная кнопка. Линза без заливки акцентом — рядом с «Играть»
/// она не должна претендовать на внимание, но и плашкой быть не должна:
/// кадр под ней виден и гнётся у кромки, а под курсором она разгорается
/// изнутри и прижимается при нажатии.
class EvGhostButton extends StatefulWidget {
  const EvGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 56,
    this.danger = false,
    this.grouped = false,
  }) : iconOnly = false;

  /// Только иконка, квадратом по высоте: место в полосе действий дорого,
  /// а «проверить файлы» и «открыть папку» узнаются по знаку. [label]
  /// остаётся — его читает экранный диктор и показывает подсказка.
  const EvGhostButton.icon({
    super.key,
    required String this.icon,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.danger = false,
    this.grouped = false,
  }) : iconOnly = true;

  final String label;

  /// `null` — действия пока нет: кнопка выглядит так же, но не нажимается
  /// и фокус не получает.
  final VoidCallback? onPressed;
  final String? icon;
  final double height;

  /// Красный свет на кромке — для необратимого.
  final bool danger;

  /// Кнопки одной строки читают фон один раз на всех.
  final bool grouped;

  /// Подпись не показывается, кнопка становится квадратной.
  final bool iconOnly;

  @override
  State<EvGhostButton> createState() => _EvGhostButtonState();
}

class _EvGhostButtonState extends State<EvGhostButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final accent = widget.danger ? EvColors.bad : c.ink;
    final lit = _hover && widget.onPressed != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: EvFocusable(
          onActivate: widget.onPressed,
          radius: ev.radii.pill,
          child: Semantics(
            button: true,
            label: widget.iconOnly ? widget.label : null,
            child: EvGlass(
            style: EvGlassStyle.lens,
            borderRadius: ev.radii.bPill,
            grouped: widget.grouped,
            interactive: true,
            pressed: _pressed,
            keyLight: widget.danger && lit ? EvColors.bad : null,
            tint: lit
                ? c.surface.withValues(alpha: 0.6)
                : c.sub.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(
              horizontal: widget.iconOnly ? 0 : 20,
            ),
            child: SizedBox(
              height: widget.height,
              width: widget.iconOnly ? widget.height : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    EvIcon(
                      widget.icon!,
                      size: 17,
                      color: lit ? accent : c.ink2,
                    ),
                    if (!widget.iconOnly) const SizedBox(width: 9),
                  ],
                  // 15 px, как у «Играть»: кнопки одной строки — одним кеглем
                  if (!widget.iconOnly)
                    Text(
                      widget.label,
                      style: ev.text.body.copyWith(
                        fontSize: 15,
                        color: lit ? accent : c.ink2,
                      ),
                    ),
                ],
                ),
              ),
            ),
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

  /// `null` — действия пока нет: кнопка выглядит так же, но не
  /// нажимается и фокус не получает.
  final VoidCallback? onPressed;

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
        child: EvGlass(
          style: EvGlassStyle.chip,
          backdrop: false,
          interactive: true,
          borderRadius: ev.radii.bPill,
          keyLight: widget.danger && _hover ? EvColors.bad : null,
          tint: c.ink.withValues(alpha: _hover ? 0.07 : 0.03),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  EvIcon(
                    widget.icon!,
                    size: 13,
                    color: _hover ? accent : c.ink3,
                  ),
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
///
/// Выбранное помечено каплей стекла: она не перескакивает, а перетекает
/// к новому сегменту, вытягиваясь по дороге.
class EvSegmented<T> extends StatefulWidget {
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
  State<EvSegmented<T>> createState() => _EvSegmentedState<T>();
}

class _EvSegmentedState<T> extends State<EvSegmented<T>> {
  final _track = GlobalKey();
  final _keys = <T, GlobalKey>{};
  Map<T, Rect> _rects = {};

  @override
  void initState() {
    super.initState();
    _scheduleMeasure();
    // Ширина сегмента — это ширина слова, а шрифты догружаются уже после
    // первого кадра: без пересчёта капля осталась бы мерой запасного.
    PaintingBinding.instance.systemFonts.addListener(_scheduleMeasure);
  }

  @override
  void didUpdateWidget(EvSegmented<T> old) {
    super.didUpdateWidget(old);
    _scheduleMeasure();
  }

  @override
  void dispose() {
    PaintingBinding.instance.systemFonts.removeListener(_scheduleMeasure);
    super.dispose();
  }

  void _scheduleMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final track = _track.currentContext?.findRenderObject();
    if (track is! RenderBox || !track.hasSize) return;
    final rects = <T, Rect>{};
    for (final entry in _keys.entries) {
      final box = entry.value.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      rects[entry.key] =
          box.localToGlobal(Offset.zero, ancestor: track) & box.size;
    }
    if (mapEquals(rects, _rects)) return;
    setState(() => _rects = rects);
  }

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final selected = _rects[widget.value];
    return EvGlass(
      style: EvGlassStyle.chip,
      backdrop: false,
      borderRadius: ev.radii.bPill,
      tint: c.ground.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(2),
      child: Stack(
        key: _track,
        children: [
          if (selected != null)
            EvDroplet(
              rect: selected,
              radius: ev.radii.bPill,
              duration: EvMotion.popover,
              tint: c.ink.withValues(alpha: 0.1),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in widget.items.entries)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => widget.onChanged(e.key),
                    child: Padding(
                      key: _keys[e.key] ??= GlobalKey(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: Text(
                        e.value,
                        style: ev.text.data.copyWith(
                          color: e.key == widget.value ? c.ink : c.ink3,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
